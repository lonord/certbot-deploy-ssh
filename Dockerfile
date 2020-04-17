FROM alpine:3.11

COPY entrypoint.sh /entrypoint.sh

VOLUME /root/.ssh

# certificates
# /etc/letsencrypt/live/abc.com/fullchain.pem
# /etc/letsencrypt/live/abc.com/privkey.pem
VOLUME /etc/letsencrypt

# cert need to deploy
ENV CERT ""
# remote connection command of ssh
# username@abc.com
ENV REMOTE_CONN ""
# cert file to copy to on remote server
ENV CERT_DEPLOY_PATH ""
# key file to copy to on remote server
ENV KEY_DEPLOY_PATH ""
# command to exec after cert and key files deployed
ENV EXEC_DEPLOY_CMD ""

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache \
    openssh-client \
    ca-certificates \
    bash

ENTRYPOINT [ "/entrypoint.sh" ]