#!/bin/sh

cd /mc/
mv config.cfg server/config.cfg

cd /mc/server/
. config.cfg

[ ! -f "server-$MC_NAME-$MC_VER.jar" ] && wget $SRV_URL -O "server-$MC_NAME-$MC_VER.jar"
echo "eula=true" > eula.txt

cd /mc/
/bin/sh start.sh
