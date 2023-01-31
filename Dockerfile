FROM eclipse-temurin:17-jre-alpine

VOLUME /mc/server
WORKDIR /mc

COPY entry.sh .
COPY start.sh .
COPY def_config.cfg .

EXPOSE 25565

ENTRYPOINT ["/bin/sh", "entry.sh"]
