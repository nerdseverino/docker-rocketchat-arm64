# Bundle vem da imagem OFICIAL rocketchat/rocket.chat:<RC_VERSION> (arm64), nao do tarball de
# releases.rocket.chat (o alias 9.0.0 serviu um build do develop, 9.1.0-develop).
# O bundle oficial e Alpine/musl; os modulos nativos sao reinstalados em Debian/glibc no estagio builder.
ARG RC_VERSION=9.0.0
# Pin opcional do manifest arm64 (formato @sha256:...). Vazio = usa a tag.
ARG OFFICIAL_DIGEST=@sha256:523c2b26ca4b1d3a78029380669d5c7986dffebbc15ffca0b552a58264f60d2e
# Hash (ou prefixo) do commit esperado da tag. Vazio = nao confere o hash.
ARG RC_COMMIT=756135f4a99535b1bbc1f7e3779a1035dbd20450

FROM rocketchat/rocket.chat:${RC_VERSION}${OFFICIAL_DIGEST} AS official

FROM node:24-trixie-slim AS builder

ARG RC_VERSION
ARG RC_COMMIT
ARG SHARP_VERSION=0.35.5
ARG SHARP_LIBVIPS_VERSION=1.3.4

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes
ENV NODE_ENV=production

RUN apt-get update \
  && apt-get install -y --no-install-recommends g++ make python3 ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=official /app/bundle /app/bundle
COPY scripts/verify-bundle.js /tmp/verify-bundle.js

# Trava: o build falha se o bundle nao for a release RC_VERSION (ex.: build do develop)
RUN node /tmp/verify-bundle.js /app/bundle "${RC_VERSION}" "${RC_COMMIT}"

# Recompila os nativos para glibc (npm-rebuild.js do Meteor roda "npm rebuild" nos diretorios do bundle)
# e adiciona os binarios glibc do sharp (o bundle oficial so traz os musl).
RUN set -eux \
  && cd /app/bundle/programs/server \
  && npm install --unsafe-perm \
  && mkdir /tmp/sharp-glibc && cd /tmp/sharp-glibc \
  && npm install --no-save --no-package-lock --ignore-scripts --cpu=arm64 --os=linux --libc=glibc \
       @img/sharp-linux-arm64@${SHARP_VERSION} @img/sharp-libvips-linux-arm64@${SHARP_LIBVIPS_VERSION} \
  && cp -a node_modules/@img/. /app/bundle/programs/server/npm/node_modules/@img/ \
  && npm cache clear --force \
  && rm -rf /tmp/sharp-glibc

FROM node:24-trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NOWARNINGS=yes

RUN groupadd -r rocketchat \
  && useradd -r -g rocketchat rocketchat \
  && mkdir -p /app/uploads \
  && chown rocketchat:rocketchat /app/uploads \
  && apt-get update \
  && apt-get install -y --no-install-recommends fontconfig \
  && rm -rf /var/lib/apt/lists/*

VOLUME /app/uploads

WORKDIR /app

ENV NODE_ENV=production

ARG RC_VERSION
ENV RC_VERSION=${RC_VERSION}

COPY --from=builder --chown=rocketchat:rocketchat /app/bundle /app/bundle

USER rocketchat

WORKDIR /app/bundle

# needs a mongoinstance - defaults to container linking with alias 'db'
ENV DEPLOY_METHOD=docker-official \
  MONGO_URL=mongodb://db:27017/meteor \
  HOME=/tmp \
  PORT=3000 \
  ROOT_URL=http://localhost:3000

EXPOSE 3000

CMD ["node", "main.js"]
