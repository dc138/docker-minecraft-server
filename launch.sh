#!/bin/sh

# See https://fabricmc.net/use/server/
# To change the minecraft version just change MC_VER
MC_VER=1.19.3
LAUNCHER_VER=0.14.13
INSTALLER_VER=0.11.1

cd /mc/server/

[ ! -f "fabric.jar" ] && wget "https://meta.fabricmc.net/v2/versions/loader/$MC_VER/$LAUNCHER_VER/$INSTALLER_VER/server/jar" -O fabric.jar
echo "eula=true" > eula.txt

cd /mc/

/bin/sh start.sh
