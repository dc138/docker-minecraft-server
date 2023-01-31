FROM eclipse-temurin:17-jre-alpine

VOLUME /mc/server
WORKDIR /mc

COPY entry.sh .
COPY start.sh .
COPY def_config.cfg .
RUN wget "https://meta.fabricmc.net/v2/versions/loader/1.19.3/0.14.13/0.11.1/server/jar" -O def_server.jar

EXPOSE 25565

ENTRYPOINT ["/bin/sh", "entry.sh"]
