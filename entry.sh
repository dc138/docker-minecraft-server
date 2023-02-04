#!/bin/sh

cd /mc/

[ ! -f "server/config.cfg" ] && cp runtime_config.cfg server/config.cfg
[ ! -f "server/server.jar" ] && cp def_server.jar server/server.jar

if [ ! -f "server/server.properties" ]; then
  echo "enable-rcon=true" > server/server.properties
  echo "rcon.password=rconpass" >> server/server.properties
fi

echo "eula=true" > server/eula.txt

/bin/sh start.sh
