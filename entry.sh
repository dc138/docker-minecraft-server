#!/bin/sh

cd /mc/

[ ! -f "server/config.cfg" ] && mv config.cfg server/config.cfg || rm config.cfg
. server/config.cfg

if [ ! -f "server/server.properties" ]; then
  echo "enable-rcon=true" > server/server.properties
  echo "rcon.password=rconpass" >> server/server.properties
fi

echo "eula=true" > server/eula.txt

wget $SERVER_URL -O server/server.jar

/bin/sh start.sh
