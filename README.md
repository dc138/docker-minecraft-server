# Docker Minecraft Server

A simple docker image to run a minecraft server in a docker container.
Downloads the desired minecraft version and flavour on startup and automatically launches it.
You must mount `/mc/server` as a volume in your host machine to persist data across container launches.
Supports both automatically downloading `vanilla`, `fabric`, `forge`, `spigot` and `paper` server jars, and using a custom server url link.


## Building the image

Note that you might need to change the java version used by the container to run older minecraft server versions.

### From source

```bash
git clone git@github.com:DarthChungo/docker-minecraft-server.git
cd docker-minecraft-server
```

```bash
docker build -t darthchungo/docker-minecraft-server:latest .
```

### From docker hub

Alternatively, you can download a prebuilt image from docker hub:

```bash
docker pull darthchungo/docker-minecraft-server:latest
```


## Running the image

Now create a directory to store the server data, like `data/`, for example, and run the container:

```bash
docker run -d -e "EULA=true" -p 25565:25565 -v $(pwd)/data:/mc/server darthchungo/docker-minecraft-server:latest
```

The first time you run it, it will download the specified server jar automatically, and store its version and flavour inside a `tag.txt` file.
This way, when you restart the container, the installed server version can be detected, and the download skipped if the version found matches the one requested.


## Configuration

Configuration is handled through the docker environment.
Currently used arguments:
- `SERVER_TYPE`: server flavour, use `vanilla`, `fabric`, `forge` or `spigot`
- `SERVER_VERSION`: available options vary depending on flavour:
  - `vanilla` and `fabric`:
    - `latest`: for latest release
    - `latest-snapshot`: for latest snapshot
    - `<version_number>`: for a specific version number (including snapshots)
  - __*__`spigot` and `paper`:
    - `latest`: for latest published version
    - `<version_number>`: for a specific minecraft version
  - __*__`forge`:
    - `latest`: for latest published forge version
    - `latest-recommended`: for latest recommended forge version
    - `<version_number>-latest`: latest forge version for a certain minecraft version
    - `<version_number>-recommended` or `<version_number>`: latest recommended forge version for a certain minecraft version
- `SERVER_CUSTOM_URL`: a custom URL to download the server from. Bypasses `SERVER_VERSION` if used.
- `EULA`: `true` or `TRUE` to agree. Server will not start unless set.
- `JVM_FLAGS`: custom arguments to the JVM.
- `UID` and `GID`: run the server with a custom user and group.

*Note: flavours marked with*
_*_
*do not provide snapshot builds.*

## Running commands

To run a command inside the container, use:

```bash
docker exec -it <container_id> cmd <command>
```

Where `<container_id>` is the docker container id (use `docker container ls`), and `<command>` is the command.
If `<command>` is left empty, it will drop you into an interactive shell, provided you keep the `-it` flags.
You may also choose to modify the image to expose port `25575` and connect to it through RCON directly with the default password, `rconpass`.


# License

```
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
```
