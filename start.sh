#!/bin/sh

cd /mc/server/
. config.cfg

if [ "$SERVER_TYPE" = "forge" ]; then
  java $JVM_FLAGS $(cat libraries/net/minecraftforge/forge/$SERVER_VERSION-*/unix_args.txt)
else
  java $JVM_FLAGS -jar server.jar nogui
fi
