# Backstage app

Main Backstage source code for the Developer Portal.

## Local run (from this directory)

```bash
corepack enable
yarn install
export POSTGRES_HOST=localhost POSTGRES_PORT=5432 POSTGRES_DB=backstage POSTGRES_USER=backstage POSTGRES_PASSWORD=backstage-dev-password
export GITHUB_TOKEN=<your-token> K8S_CLUSTER_NAME=minikube K8S_CLUSTER_URL=https://kubernetes.default.svc
yarn start
```

## Notes

- Uses PostgreSQL (configured in `app-config.yaml` and `app-config.production.yaml`).
- Catalog loads local entities from `../catalog` and `../services`.
