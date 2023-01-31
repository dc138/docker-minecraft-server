FROM eclipse-temurin:17-jre-alpine

VOLUME /mc/server
WORKDIR /mc

COPY entry.sh .
COPY start.sh .
COPY def_config.cfg .
COPY cmd.sh .
RUN chmod +x cmd.sh

RUN wget "https://meta.fabricmc.net/v2/versions/loader/1.19.3/0.14.13/0.11.1/server/jar" -O def_server.jar
RUN wget "https://github.com/itzg/rcon-cli/releases/download/1.6.1/rcon-cli_1.6.1_linux_amd64.tar.gz" -O- | tar xzf - rcon-cli

RUN mv rcon-cli /usr/bin
RUN mv cmd.sh /usr/bin/cmd

EXPOSE 25565

ENTRYPOINT ["/bin/sh", "entry.sh"]
