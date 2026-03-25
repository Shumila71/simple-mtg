FROM alpine:latest

RUN apk add --no-cache bash curl go git

RUN curl -L -o /tmp/mtg.tar.gz \
    https://github.com/9seconds/mtg/releases/download/v2.2.4/mtg-2.2.4-linux-amd64.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp \
    && cp /tmp/mtg-2.2.4-linux-amd64/mtg /usr/local/bin/ \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/mtg.tar.gz /tmp/mtg-2.2.4-linux-amd64

RUN mtg --version

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3128

ENTRYPOINT ["/entrypoint.sh"]