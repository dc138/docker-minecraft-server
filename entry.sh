#!/bin/sh

# $1: minecraft flavour ("vanilla", "fabric", "forge")
# $2: minecraft version ("1.19.3", ...)
get_download_url() {
  case $1 in
    "vanilla")
      version="\"$2\""
      version_meta_url=$(wget -q "https://launchermeta.mojang.com/mc/game/version_manifest.json" -O- | jq -r ".versions | map({id , url}) | .[] | select(.id == $version).url")
      wget -q $version_meta_url -O- | jq -r ".downloads.server.url";;

    "fabric")
      echo "https://meta.fabricmc.net/v2/versions/loader/$2/0.14.14/0.11.1/server/jar";;

    "forge")
      version="\"$2-recommended\""
      forge_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r ".promos.$version")
      echo "https://maven.minecraftforge.net/net/minecraftforge/forge/$2-$forge_version/forge-$2-$forge_version-installer.jar";;
  esac
}

cd /mc/
echo "Copying files..."

[ ! -f "server/config.cfg" ] && mv config.cfg server/config.cfg || rm config.cfg
. server/config.cfg

if [ ! -f "server/server.properties" ]; then
  echo "enable-rcon=true" > server/server.properties
  echo "rcon.password=rconpass" >> server/server.properties
fi

echo "eula=true" > server/eula.txt

if [ ! -z $SERVER_URL ]; then
  $url=$SERVER_URL
  echo Using \"$SERVER_URL\" as custom server url
else
  url=$(get_download_url $SERVER_TYPE $SERVER_VERSION)
  echo Using \"$url\" as $SERVER_TYPE server url
fi

if [ ! "$SERVER_TYPE" = "forge" ]; then
  echo Downloading server...
  wget -q $url -O server/server.jar

else
  echo Unpacking server jar and config...
  tmp=$(mktemp -d)
  cd $tmp

  wget -q $url -O installer.jar
  java -jar installer.jar --installServer

  rm -rv /mc/server/libraries
  rm -rv /mc/server/server.jar
  cp -rv libraries/ /mc/server

  cd /mc/
  rm -rv $tmp
fi

/bin/sh start.sh
#/bin/sh -i
