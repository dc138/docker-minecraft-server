#!/bin/sh

#
# Docker Minecraft Server, a simple docker image to run a minecraft server.
# Copyright © 2023 Antonio de Haro
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Inputs
# $1: minecraft flavour ("vanilla", "fabric", "forge", "spigot", "paper")
# $2: minecraft version ("1.19.3", "latest", ...)
# Ouputs
# url: download url
# version: actual game version (i.e. latest would become 1.19.3)
get_version_info() {
  case $1 in
    "spigot")
      if [ "$2" = "latest" ]; then
        version=$(wget -q "https://hub.spigotmc.org/nexus/content/repositories/snapshots/org/spigotmc/spigot-api/maven-metadata.xml" -O- | yq -pxml ".metadata.versioning.latest" | cut -d- -f1)

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

    "paper")
      if [ "$2" = "latest" ]; then
        version=$(wget -q "https://api.papermc.io/v2/projects/paper/" -O- | jq -r ".versions | last")

      elif $(echo $2 | grep -Eq "[0-9]+\.[0-9]+(\.[0-9]+)?"); then
        version=$2
      fi

      paper_version=$(wget -q "https://api.papermc.io/v2/projects/paper/versions/$version/" -O- | jq -r ".builds | last")
      url="https://api.papermc.io/v2/projects/paper/versions/$version/builds/$paper_version/downloads/paper-$version-$paper_version.jar";;

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
        version=$(echo $full_version | jq -r ".key" | cut -d- -f1)
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
  flavour="custom"

  echo Using \"$CUSTOM_SERVER_URL\" as custom server url

else
  get_version_info $SERVER_TYPE $SERVER_VERSION
  flavour=$SERVER_TYPE

  echo Using \"$url\" as $SERVER_TYPE server url
fi

tag="$url $version $flavour"

if [ -d server ] && [ -e server/tag.txt ] && [ \( -e server/server.jar \) -o \( "$SERVER_TYPE" = "forge" \) ] && [ "$tag" = "$(cat server/tag.txt)" ]; then
  echo "Using existing server"

else
  echo "Downloading sever jar for the first time"

  rm -rvf /mc/server/libraries
  rm -rvf /mc/server/server.jar

  if [ "$flavour" = "spigot" ]; then
    echo Compiling spigot server from source, this may take a while...
    tmp=$(mktemp -d)
    cd $tmp

    wget -q $url -O build_tools.jar
    java -jar build_tools.jar --rev $version --compile SPIGOT

    if [ -f spigot-*.jar ]; then
      cp -v spigot-*.jar /mc/server/server.jar

    else
      echo Builds tools didnt produce a server jar, aborting...
      exit
    fi

    cd /mc/
    rm -rvf $tmp

  elif [ "$flavour" = "forge" ]; then
    echo Unpacking forge server jar and config, this may take a while...
    tmp=$(mktemp -d)
    cd $tmp

    wget -q $url -O installer.jar
    java -jar installer.jar --installServer

    rm -vf /mc/server/server.jar
    cp -rvf libraries/ /mc/server

    cd /mc/
    rm -rvf $tmp

  else
    echo Downloading server...
    wget -q $url -O server/server.jar
  fi
fi

cd /mc/server/
echo $tag > tag.txt

chown -R $UID:$GID .

if [ "$flavour" = "forge" ]; then
  exec setpriv --reuid $UID --regid $GID --clear-groups java $JVM_FLAGS $(cat libraries/net/minecraftforge/forge/*/unix_args.txt)

else
  exec setpriv --reuid $UID --regid $GID --clear-groups java $JVM_FLAGS -jar server.jar nogui
fi
