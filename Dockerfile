FROM eclipse-temurin:17-jre-alpine

VOLUME /mc/server
WORKDIR /mc

COPY launch.sh .
COPY start.sh .
COPY def_config.cfg .

EXPOSE 25565

ENTRYPOINT ["/bin/sh", "launch.sh"]
