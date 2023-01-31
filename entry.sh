#!/bin/sh

cd /mc/server/

[ ! -f "config.cfg" ] && cp ../def_config.cfg config.cfg
. config.cfg

[ ! -f "server-$MC_NAME-$MC_VER.jar" ] && wget $SRV_URL -O "server-$MC_NAME-$MC_VER.jar"

echo "eula=true" > eula.txt

cd /mc/
/bin/sh start.sh
