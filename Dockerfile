FROM eclipse-temurin:17-jre-alpine

WORKDIR /mc

RUN mkdir server
COPY launch.sh .
EXPOSE 25565

VOLUME /mc/world
VOLUME /mc/config
VOLUME /mc/mods

ENTRYPOINT ["/bin/sh", "launch.sh"]
