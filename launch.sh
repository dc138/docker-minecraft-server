#!/bin/sh

cd server

wget "https://meta.fabricmc.net/v2/versions/loader/1.19.3/0.14.13/0.11.1/server/jar" -O fabric.jar
echo "eula=true" > eula.txt

java -jar fabric.jar nogui
