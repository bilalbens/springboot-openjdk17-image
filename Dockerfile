FROM alpine
ENV LANG en_US.UTF-8
RUN apk add openjdk17 bash fontconfig ttf-dejavu && rm -rf /var/cache/apk/*
RUN mkdir -p /app
COPY start.sh /
WORKDIR /app
ENTRYPOINT /start.sh
