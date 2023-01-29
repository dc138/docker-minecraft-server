#!/bin/sh

# See https://fabricmc.net/use/server/
# To change the minecraft version just change MC_VER
MC_VER=1.19.3
LAUNCHER_VER=0.14.13
INSTALLER_VER=0.11.1

if [ $(find worlds/ -mindepth 1 -type d | wc -l) = 0 ]; then
  echo "No worlds found, creating default..."
else
  echo Linking worlds...

  for world in $(find worlds/ -type d -mindepth 1); do
    echo $world
  done
fi


cd server

wget "https://meta.fabricmc.net/v2/versions/loader/$MC_VER/$LAUNCHER_VER/$INSTALLER_VER/server/jar" -O fabric.jar
echo "eula=true" > eula.txt

#java -jar fabric.jar nogui
/bin/sh -i
