FROM alpine:latest AS builder

RUN apk add --no-cache bash curl

FROM nineseconds/mtg:2

COPY --from=builder /bin/bash /bin/bash
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/lib/libcurl.so* /usr/lib/
COPY --from=builder /lib/libssl.so* /lib/
COPY --from=builder /lib/libcrypto.so* /lib/
COPY --from=builder /lib/libz.so* /lib/
COPY --from=builder /lib/ld-musl-x86_64.so* /lib/  

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3128

ENTRYPOINT ["/entrypoint.sh"]