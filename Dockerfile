FROM eclipse-temurin:17-jre-alpine
RUN apk add jq git

VOLUME /mc/server
WORKDIR /mc

ENV SERVER_TYPE="vanilla"
ENV SERVER_VERSION="latest"
ENV SERVER_CUSTOM_URL=""
ENV EULA="false"

COPY entry.sh .
COPY start.sh .
COPY cmd.sh .

RUN wget "https://github.com/itzg/rcon-cli/releases/download/1.6.1/rcon-cli_1.6.1_linux_amd64.tar.gz" -O- | tar xzf - rcon-cli

RUN chmod +x cmd.sh
RUN mv rcon-cli /usr/bin
RUN mv cmd.sh /usr/bin/cmd

EXPOSE 25565

ENTRYPOINT ["/bin/sh", "entry.sh"]
