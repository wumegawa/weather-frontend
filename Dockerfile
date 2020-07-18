FROM node:14.5.0-alpine

WORKDIR /app

RUN apk update && \
    apk add --no-cache && \
    apk add alpine-sdk && \
    apk add git && \
    npm install -g npm && \
    npm install -g @vue/cli

EXPOSE 8080

COPY package.json /

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["yarn", "serve"]
