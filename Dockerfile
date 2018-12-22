FROM alpine:3.8

WORKDIR /usr/src/app

COPY _build/default/rel/beerl/beerl-0.0.1.tar.gz .
RUN tar xvf ./beerl-0.0.1.tar.gz -C /usr/local

EXPOSE 9376

CMD ["/usr/local/bin/beerl", "foreground"]
