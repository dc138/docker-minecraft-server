#!/bin/sh

cd /mc/

[ ! -f "server/config.cfg" ] && cp def_config.cfg server/config.cfg
[ ! -f "server/server.jar" ] && cp def_server.jar server/server.jar

echo "eula=true" > server/eula.txt

/bin/sh start.sh
