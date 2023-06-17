#!/bin/sh

# Inputs
# $1: minecraft flavour ("vanilla", "fabric", "forge", "spigot")
# $2: minecraft version ("1.19.3", "latest", ...)
# Ouputs
# url: download url
# version: actual game version (i.e. latest would become 1.19.3)
get_version_info() {
  case $1 in
    "spigot")
      if [ "$2" = "latest" ]; then
        version=$(wget -q "https://hub.spigotmc.org/nexus/content/repositories/snapshots/org/spigotmc/spigot-api/maven-metadata.xml" -O- | yq -pxml -r ".metadata.versioning.latest" | cut -d- -f1)

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+(\.[0-9]+)?"); then
        version=$2
      fi

      url="https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar";;

    "vanilla")
      if [ "$2" = "latest" ]; then
        version=$(wget -q "https://launchermeta.mojang.com/mc/game/version_manifest.json" -O- | jq -r ".latest.release")
        version_="\"$version\""

      elif [ "$2" = "latest-snapshot" ]; then
        version=$(wget -1 "https://launchermeta.mojang.com/mc/game/version_manifest.json" -O- | jq -r ".latest.snapshot")
        version_="\"$version\""

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+(\.[0-9]+)?"); then
        version=$2
        version_="\"$version_\""
      fi

      version_meta_url=$(wget -q "https://launchermeta.mojang.com/mc/game/version_manifest.json" -O- | jq -r ".versions | map({id , url}) | .[] | select(.id == $version_).url")
      url=$(wget -q $version_meta_url -O- | jq -r ".downloads.server.url");;

    "fabric")
      if [ "$2" = "latest" ]; then
        version=$(wget -q "https://meta.fabricmc.net/v2/versions" -O- | jq -r "[.game | .[] | select(.stable)][0].version")

      elif [ "$2" = "latest-snapshot" ]; then
        version=$(wget -q "https://meta.fabricmc.net/v2/versions" -O- | jq -r ".game[0].version")

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+(\.[0-9]+)?"); then
        version=$2
      fi

      url="https://meta.fabricmc.net/v2/versions/loader/$version/0.14.14/0.11.1/server/jar";;

    "forge")
      if [ "$2" = "latest-recommended" ]; then
        full_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r '.promos | to_entries | map(select(.key | match(".{6}-recommended"))) | .[-1]')
        version=$(echo $full_version | jq -r ".key" | cut -d- -f1)
        forge_version=$(echo $full_version | jq -r ".value")

      elif [ "$2" = "latest" ]; then
        full_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r '.promos | to_entries | map(select(.key | match(".{6}-latest"))) | .[-1]')
        version=$(echo $full_version | jq -r ".key" | cut -d- -f1)_
        forge_version=$(echo $full_version | jq -r ".value")

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+(\.[0-9]+)?-latest"); then
        version=$(echo $2 | cut -d- -f1)
        version_name="\"$version-latest\""
        forge_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r ".promos.$version_name")

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+(\.[0-9]+)?") || $(echo $2 | grep -Eq "[0-9]+\.[0-9]+(\.[0-9]+)?-recommended"); then
        version=$(echo $2 | cut -d- -f1)
        version_name="\"$version-recommended\""
        forge_version=$(wget -q "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" -O- | jq -r ".promos.$version_name")
      fi

      url="https://maven.minecraftforge.net/net/minecraftforge/forge/$version-$forge_version/forge-$version-$forge_version-installer.jar";;
  esac
}

cd /mc/
echo "Copying files..."

if [ ! -f "server/server.properties" ]; then
  echo "enable-rcon=true" > server/server.properties
  echo "rcon.password=rconpass" >> server/server.properties
fi

if [ "$EULA" = "true" ] || [ "$EULA" = "TRUE" ]; then
  echo "eula=true" > server/eula.txt
else
  echo "eula=false" > server/eula.txt
fi

if [ ! -z $CUSTOM_SERVER_URL ]; then
  url=$CUSTOM_SERVER_URL
  version="custom"
  flavour="custom"
  echo Using \"$CUSTOM_SERVER_URL\" as custom server url
else
  get_version_info $SERVER_TYPE $SERVER_VERSION
  flavour=$SERVER_TYPE
  echo Using \"$url\" as $SERVER_TYPE server url
fi

#echo "$url $version $flavour"
#exit

rm -rv /mc/server/libraries
rm -rv /mc/server/server.jar

if [ "$flavour" = "spigot" ]; then
  echo Compiling spigot server from source, this may take a while...
  tmp=$(mktemp -d)
  cd $tmp

  wget -q $url -O build_tools.jar
  java -jar build_tools.jar --rev $flavour --compile SPIGOT

  if [ -f spigot-*.jar ]; then
    cp -v spigot-*.jar /mc/server/server.jar

  else
    echo Builds tools didnt produce a server jar, aborting...
    exit
  fi

  cd /mc/
  rm -rv $tmp

elif [ "$flavour" = "forge" ]; then
  echo Unpacking forge server jar and config, this may take a while...
  tmp=$(mktemp -d)
  cd $tmp

  wget -q $url -O installer.jar
  java -jar installer.jar --installServer

  rm /mc/server/server.jar
  cp -rv libraries/ /mc/server

  cd /mc/
  rm -rv $tmp

else
  echo Downloading server...
  wget -q $url -O server/server.jar
fi

/bin/sh start.sh
