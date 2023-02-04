# Docker Minecraft Server

A simple docker image to run a minecraft server in a docker container.
Comes embedded with the desired minecraft server image and a RCON client to easily run commands inside the container.
You can mount `/mc/server` as a volume in your host machine to persist data across container launches.


## Building the image

### From source

```bash
git clone git@github.com:DarthChungo/docker-minecraft-server.git
cd docker-minecraft-server
```

```bash
docker build -t darthchungo/docker-minecraft-server:fabric-1.19.3 .
```

### From docker hub

Alternatively, you can download a prebuilt image from docker hub:

```bash
docker pull darthchungo/docker-minecraft-server:fabric-1.19.3
```


## Running the image

Now create a directory to store the server data, like `data`, and run the container:

```bash
docker run -d -p 25565:25565 -v $(pwd)/data:/mc/server darthchungo/docker-minecraft-server:fabric-1.19.3
```


## Running commands

To run a command inside the container, use:

```bash
docker exec -it <container_id> cmd <command>
```

Where `<container_id>` is the docker container id (use `docker container ls`), and `<command>` is the command.
If `<command>` is left empty, it will drop you into an interactive shell, provided you keey the `-it` flags.
You may also choose to modify the image to expose port `25575` and connect to it through RCON directly with the default password, `rconpass`.


## Modifying the image

Configuration is handled with two files, `build_config.cfg` and `runtime_config.cfg`.
The former contains configuration to be used while builing the image, like the server jar to embed.
The latter contains runtime configuration used while launching the server, and is copied to `/mc/server` when the container starts to persist changes.


# License

Docker Minecraft Server, a simple docker image to run a minecraft server.

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
