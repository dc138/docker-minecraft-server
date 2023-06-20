FROM eclipse-temurin:17-jre-alpine
RUN apk add jq yq git setpriv

# Environment variables

ENV JVM_FLAGS="-Xms512M -Xmx1024M"
ENV EULA="false"

ENV SERVER_TYPE="vanilla"
ENV SERVER_VERSION="latest"
ENV SERVER_CUSTOM_URL=""

ENV UID=1000
ENV GID=1000

# Setup tools

WORKDIR /tmp

RUN wget "https://github.com/itzg/rcon-cli/releases/download/1.6.1/rcon-cli_1.6.1_linux_amd64.tar.gz" -O- | tar xzf - rcon-cli
COPY cmd.sh .

RUN chmod +x cmd.sh
RUN mv rcon-cli /usr/bin
RUN mv cmd.sh /usr/bin/cmd

# Run server

VOLUME /mc/server
WORKDIR /mc

COPY entry.sh .

EXPOSE 25565

ENTRYPOINT ["/bin/sh", "entry.sh"]
