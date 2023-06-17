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

cd /mc/server/

if [ "$SERVER_TYPE" = "forge" ]; then
  java $JVM_FLAGS $(cat libraries/net/minecraftforge/forge/*/unix_args.txt)

else
  java $JVM_FLAGS -jar server.jar nogui
fi
