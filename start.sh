#!/bin/sh

cd /mc/server/
. config.cfg

java $JVM_FLAGS -jar server.jar nogui
