FROM node:22-bookworm-slim AS builder

ENV PYTHON=/usr/bin/python3

RUN apt-get update && apt-get install -y --no-install-recommends python3 g++ build-essential && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/backstage

COPY backstage/.yarn ./.yarn
COPY backstage/.yarnrc.yml ./
COPY backstage/backstage.json ./
COPY backstage/package.json ./
COPY backstage/yarn.lock ./
COPY backstage/tsconfig.json ./
COPY backstage/app-config.yaml ./
COPY backstage/app-config.production.yaml ./
COPY backstage/catalog-info.yaml ./
COPY backstage/mkdocs.yml ./
COPY backstage/packages ./packages
COPY backstage/plugins ./plugins
COPY backstage/examples ./examples
COPY backstage/docs ./docs
COPY catalog /workspace/catalog
COPY services /workspace/services

RUN corepack enable && yarn install
RUN yarn tsc && yarn build:backend

FROM node:22-bookworm-slim

ENV PYTHON=/usr/bin/python3
RUN apt-get update && apt-get install -y --no-install-recommends python3 g++ build-essential && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /workspace/backstage ./
COPY --from=builder /workspace/catalog ./catalog
COPY --from=builder /workspace/services ./services

ENV NODE_ENV=production
ENV NODE_OPTIONS=--no-node-snapshot

RUN tar xzf packages/backend/dist/skeleton.tar.gz -C /app && \
    tar xzf packages/backend/dist/bundle.tar.gz -C /app

EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
