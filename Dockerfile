FROM eclipse-temurin:17-jre-alpine

VOLUME /mc/server
WORKDIR /mc

COPY entry.sh .
COPY start.sh .
COPY runtime_config.cfg .
COPY build_config.cfg .
COPY cmd.sh .
RUN chmod +x cmd.sh

RUN . build_config.cfg && wget $SERVER_URL -O def_server.jar
RUN . build_config.cfg && wget $RCON_URL -O- | tar xzf - rcon-cli

RUN mv rcon-cli /usr/bin
RUN mv cmd.sh /usr/bin/cmd

EXPOSE 25565

ENTRYPOINT ["/bin/sh", "entry.sh"]
