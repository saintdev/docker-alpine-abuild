FROM alpine:latest
MAINTAINER Nathan Caldwell <saintdev@gmail.com>
ENV RSA_PRIVATE_KEY_NAME ssh.rsa
ENV REPODEST /repo
ENV PKGSRC /package
RUN apk --no-cache add alpine-sdk coreutils \
  && adduser -G abuild -g "Alpine Package Builder" -D builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && mkdir "$REPODEST" "$PKGSRC" \
  && chown builder:abuild "$REPODEST" "$PKGSRC"
COPY entrypoint.sh /bin/
USER builder
RUN mkdir -p "$HOME"/.abuild
WORKDIR $PKGSRC
VOLUME /home/builder/.abuild
VOLUME /etc/apk/keys
ENTRYPOINT ["entrypoint.sh"]
CMD ["build"]
