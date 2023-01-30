#!/bin/sh

cd /mc/server/
. config.cfg

java $JVM_FLAGS -jar "server-$MC_NAME-$MC_VER.jar" nogui
