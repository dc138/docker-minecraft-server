#!/bin/sh

cd /mc/
mv config.cfg server/config.cfg

cd /mc/server/
. config.cfg

[ ! -f "server.jar" ] && wget $SRV_URL -O server.jar
echo "eula=true" > eula.txt

cd /mc/
/bin/sh start.sh
