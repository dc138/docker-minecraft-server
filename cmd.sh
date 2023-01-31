#!/bin/sh

cd /mc/server
rcon-cli --password=$(cat server.properties | grep rcon.password | cut -d= -f2) $@
