FROM golang:1.19-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git bash

RUN mkdir /go-ethereum
WORKDIR /go-ethereum
RUN go install github.com/ethereum/go-ethereum/cmd/geth@v1.10.25
RUN go install github.com/ethereum/go-ethereum/cmd/bootnode@v1.10.25
RUN go install github.com/ethereum/go-ethereum/cmd/puppeth@v1.10.25

# Pull Geth into a second stage deploy alpine container
FROM alpine:3.16.2

ARG USER=c3labs
ARG USER_UID=1000
ARG USER_GID=1000

ENV HOME=/c3labs
ENV HOME=${HOME}
ENV DATA_DIR=/data

ENV PACKAGES ca-certificates~=20220614 jq~=1.6 \
  bash~=5.1.16-r2 bind-tools~=9.16 tini~=0.19.0 \
  grep~=3.7 curl~=7.83.1-r3 sed~=4.8-r0

RUN apk add --no-cache $PACKAGES \
  && rm -rf /var/cache/apk/* \
  && addgroup -g ${USER_GID} ${USER} \
  && adduser -u ${USER_UID} -G ${USER} --shell /sbin/nologin --no-create-home -D ${USER} \
  && addgroup ${USER} tty \
  && sed -i -e "s/bin\/sh/bin\/bash/" /etc/passwd

RUN echo "[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash/bashrc

WORKDIR ${HOME}

COPY --from=builder /go/bin/geth /usr/local/bin/
COPY --from=builder /go/bin/puppeth /usr/local/bin/
COPY --from=builder /go/bin/bootnode /usr/local/bin/

RUN mkdir -p ${DATA_DIR} \
    && chown -R ${USER_UID}:${USER_GID} ${HOME} ${DATA_DIR}

VOLUME ${DATA_DIR}

USER ${USER_UID}:${USER_GID}