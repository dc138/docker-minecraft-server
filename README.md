# Docker Fabric Server

A simple docker image to run a fabric minecraft server
Automatically downloads the minecraft server jar from fabric's website and runs it.
You can mount `/mc/server` as a volume to your host machine to persist data across contaner launches.


## Building and running

```bash
git clone git@github.com:DarthChungo/docker-fabric-server.git
cd docker-fabric-server
```

```bash
docker build -t docker-fabric-server .
```

```bash
docker run -d -p 25565:25565 -v $(pwd)/data:/mc/server docker-fabric-server
```


# License

docker-fabric-server, a simple docker image to run a minecraft fabric server 

Copyright © 2023 Antonio de Haro

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
