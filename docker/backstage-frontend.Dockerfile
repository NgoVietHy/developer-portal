FROM node:22-bookworm-slim AS builder

WORKDIR /workspace/backstage

ARG BACKSTAGE_BASE_URL=http://portal.local
ARG BACKEND_BASE_URL=http://portal.local/api
ENV BACKSTAGE_BASE_URL=${BACKSTAGE_BASE_URL}
ENV BACKEND_BASE_URL=${BACKEND_BASE_URL}

COPY backstage/.yarn ./.yarn
COPY backstage/.yarnrc.yml ./
COPY backstage/backstage.json ./
COPY backstage/package.json ./
COPY backstage/yarn.lock ./
COPY backstage/tsconfig.json ./
COPY backstage/app-config.yaml ./
COPY backstage/app-config.production.yaml ./
COPY backstage/packages ./packages
COPY backstage/plugins ./plugins

RUN corepack enable && yarn install
RUN yarn workspace app build

FROM nginx:1.27-alpine

COPY docker/nginx-backstage.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /workspace/backstage/packages/app/dist /usr/share/nginx/html

EXPOSE 8080
