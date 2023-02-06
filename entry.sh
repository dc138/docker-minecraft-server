#!/bin/sh

# $1: minecraft flavour ("vanilla", "fabric", "forge")
# $2: minecraft version ("1.19.3", ...)
get_download_url() {
  case $1 in
    "vanilla")
      if [ "$2" = "latest" ]; then
        version_=$(wget "https://launchermeta.mojang.com/mc/game/version_manifest.json" -O- | jq -r ".latest.release")
        version="\"$version_\""

      elif [ "$2" = "latest-snapshot" ]; then
        version_=$(wget "https://launchermeta.mojang.com/mc/game/version_manifest.json" -O- | jq -r ".latest.snapshot")
        version="\"$version_\""

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+\.[0-9]+"); then
        version="\"$2\""
      fi

      version_meta_url=$(wget -q "https://launchermeta.mojang.com/mc/game/version_manifest.json" -O- | jq -r ".versions | map({id , url}) | .[] | select(.id == $version).url")
      wget -q $version_meta_url -O- | jq -r ".downloads.server.url";;

    "fabric")
      if [ "$2" = "latest" ]; then
        version=$(wget "https://meta.fabricmc.net/v2/versions" -O- | jq -r "[.game | .[] | select(.stable)][0].version")

      elif [ "$2" = "latest-snapshot" ]; then
        version=$(wget "https://meta.fabricmc.net/v2/versions" -O- | jq -r ".game[0].version")

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+\.[0-9]+"); then
        version=$2
      fi

      echo "https://meta.fabricmc.net/v2/versions/loader/$version/0.14.14/0.11.1/server/jar";;

    "forge")
      if [ "$2" = "latest-recommended" ]; then
        full_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r '.promos | to_entries | map(select(.key | match(".{6}-recommended"))) | .[-1]')
        version=$(echo $full_version | jq -r ".key" | cut -d- -f1)
        forge_version=$(echo $full_version | jq -r ".value")

      elif [ "$2" = "latest" ]; then
        full_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r '.promos | to_entries | map(select(.key | match(".{6}-latest"))) | .[-1]')
        version=$(echo $full_version | jq -r ".key" | cut -d- -f1)
        forge_version=$(echo $full_version | jq -r ".value")

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+\.[0-9]+-latest"); then
        version=$(echo $2 | cut -d- -f1)
        version_name="\"$version-latest\""
        forge_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r ".promos.$version_name")

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+\.[0-9]+") || $(echo $2 | grep -Eq "[0-9]+\.[0-9]+\.[0-9]+-recommended"); then
        version=$(echo $2 | cut -d- -f1)
        version_name="\"$version-recommended\""
        forge_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r ".promos.$version_name")
      fi

      echo "https://maven.minecraftforge.net/net/minecraftforge/forge/$version-$forge_version/forge-$version-$forge_version-installer.jar";;
  esac
}

cd /mc/
echo "Copying files..."

if [ ! -f "server/server.properties" ]; then
  echo "enable-rcon=true" > server/server.properties
  echo "rcon.password=rconpass" >> server/server.properties
fi

echo "eula=true" > server/eula.txt

if [ ! -z $CUSTOM_SERVER_URL ]; then
  url=$CUSTOM_SERVER_URL
  echo Using \"$CUSTOM_SERVER_URL\" as custom server url
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
