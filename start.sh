#!/bin/sh

cd /mc/server/

if [ "$SERVER_TYPE" = "forge" ]; then
  java $JVM_FLAGS $(cat libraries/net/minecraftforge/forge/*/unix_args.txt)
else
  java $JVM_FLAGS -jar server.jar nogui
fi
