#!/bin/bash

if [ "$1" == "--gaming" ]; then
    GAMING=yes
    shift
fi

INSTALL_DIR="$HOME/.local"
if [ $# -gt 0 -a ! -z "$1" ]; then
    INSTALL_DIR="$(cd "$1" && pwd)"
fi

#Download & install pacmag
scp depots:/depots/2017/.pacmag/repo_apps/pacmag /tmp/pacmag.tar.gz &&
((mkdir -p "$INSTALL_DIR" && tar -xf /tmp/pacmag.tar.gz -C "$INSTALL_DIR" && chmod +x "$INSTALL_DIR/bin/pacmag");
 rm /tmp/pacmag.tar.gz)
if [ ! -f "$INSTALL_DIR/bin/pacmag" ]; then
echo "Erreur, pacmag n'a pas été installé."
fi

#Add installPrefix to PATH if necessary
#if [ "$(command -v pacmag 2>/dev/null)" != "$INSTALL_DIR/bin/pacmag" ]; then
echo >> ~/.bashrc
echo '#Adding pacmag to PATH variables' >> ~/.bashrc
echo 'export PATH="'"$INSTALL_DIR/bin"':$PATH"' >> ~/.bashrc
echo 'export MANPATH="'"$INSTALL_DIR/share/man"':$MANPATH"' >> ~/.bashrc
echo 'export PYTHONPATH="'"$INSTALL_DIR/lib/python:$INSTALL_DIR/lib/python3.3/site-packages"':$PYTHONPATH"' >> ~/.bashrc
echo 'export PKG_CONFIG_PATH="'"$INSTALL_DIR/lib/pkgconfig:$INSTALL_DIR/lib64/pkgconfig"':$PKG_CONFIG_PATH"' >> ~/.bashrc
#fi

#Configure pacmag
rm -f ~/.pacmag.sqlite
sqlite3 ~/.pacmag.sqlite 'CREATE TABLE IF NOT EXISTS info(ID INTEGER PRIMARY KEY AUTOINCREMENT, name BLOB UNIQUE, value BLOB);'
sqlite3 ~/.pacmag.sqlite 'CREATE TABLE IF NOT EXISTS repos(ID INTEGER PRIMARY KEY AUTOINCREMENT, protocol INTEGER, port INTEGER, login BLOB, hostname BLOB, path BLOB);'
sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO info (name,value) VALUES ("install_dir","'"$INSTALL_DIR"'");'
sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO repos (protocol,port,login,hostname,path) VALUES ("1", "22", "'"$USER"'", "depots.ensimag.fr", "/depots/2017/.pacmag/repo_libs");'
sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO repos (protocol,port,login,hostname,path) VALUES ("1", "22", "'"$USER"'", "depots.ensimag.fr", "/depots/2017/.pacmag/repo_apps");'
sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO repos (protocol,port,login,hostname,path) VALUES ("1", "22", "'"$USER"'", "depots.ensimag.fr", "/depots/2017/.pacmag/repo_games");'
#if [ ! -z "$GAMING" ]; then
#sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO repos (protocol,port,login,hostname,path) VALUES ("3", "443", "", "gitlab.com", "/ensi_repos/wine/raw/master");'
#sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO repos (protocol,port,login,hostname,path) VALUES ("3", "443", "", "gitlab.com", "/ensi_repos/games/raw/master");'
#fi

sqlite3 ~/.pacmag.sqlite 'CREATE TABLE IF NOT EXISTS installedpkgs(ID INTEGER PRIMARY KEY AUTOINCREMENT, pkgname BLOB UNIQUE, fullname BLOB, description BLOB, version BLOB, install_dir BLOB, manual INTEGER);'
sqlite3 ~/.pacmag.sqlite 'CREATE TABLE IF NOT EXISTS files(ID INTEGER PRIMARY KEY AUTOINCREMENT, fullpath BLOB, pkg BLOB);'
sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO installedpkgs (pkgname,fullname,description,version,install_dir,manual) VALUES ("pacmag", "pacmag", "the best package manager ever :p", "v'$("$INSTALL_DIR/bin/pacmag" -v | grep '^pacmag version' | sed 's/^pacmag version \(.*\)/\1/')'", "'"$INSTALL_DIR"'", 1);'
sqlite3 ~/.pacmag.sqlite 'INSERT OR IGNORE INTO files (fullpath,pkg) VALUES ("'"$INSTALL_DIR/bin/pacmag"'", "pacmag");'

#Shorcuts in gnome menu
#[ "$INSTALL_DIR" != "$HOME/.local" ] && rm -f ~/.local/share/applications/pacmag && ln -sf "$INSTALL_DIR/share/applications" ~/.local/share/applications/pacmag

echo "Pacmag a bien été installé dans $INSTALL_DIR"
echo "Pour pouvoir installer des paquets, il faudra d'abord charger la liste des paquets disponibles :"
echo 'Pour cela, tapez pacmag -u'
echo 'Réouvrir le terminal avant'
