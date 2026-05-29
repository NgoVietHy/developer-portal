# Developer Portal on Kubernetes with DevSecOps

Internal Developer Portal built with Backstage for software service governance, documentation, CI/CD visibility, Kubernetes workload status, security scanning, and monitoring.

## Main stack

- Backstage (Guest auth)
- PostgreSQL
- Kubernetes (Minikube)
- GitHub Actions CI/CD
- Trivy image scanning
- Prometheus + Grafana

## Repository layout

- `backstage/`: Backstage application source and config
- `services/`: two sample microservices (`service-catalog`, `service-identity`)
- `k8s/`: Kubernetes manifests (`base` + `overlays/minikube`)
- `docker/`: Dockerfiles for split Backstage frontend/backend deployments
- `monitoring/`: monitoring values and Grafana dashboard JSON
- `scripts/`: Ubuntu setup, bootstrap, deploy, smoke-test scripts
- `.github/workflows/`: CI and deployment pipelines
- `docs/`: demo runbook and project evidence notes

## Required environment variables

Copy and update:

```bash
cp .env.example .env
```

Required keys:

- `GITHUB_TOKEN`
- `GHCR_USERNAME`
- `GHCR_TOKEN`
- `POSTGRES_*`
- `BACKSTAGE_BASE_URL`
- `BACKEND_BASE_URL`
- `K8S_CLUSTER_NAME`
- `K8S_CLUSTER_URL`

## Ubuntu 22.04 setup

```bash
chmod +x scripts/*.sh
sudo ./scripts/ubuntu-setup.sh
```

This installs Docker, kubectl, minikube, helm, trivy, and enables Node corepack.

## Bootstrap local cluster

```bash
./scripts/bootstrap-minikube.sh
```

The bootstrap script also builds 4 local images inside Minikube:

- `backstage-backend`
- `backstage-frontend`
- `service-catalog`
- `service-identity`

Apply runtime secrets/config from `.env`:

```bash
./scripts/apply-secrets-from-env.sh
```

After bootstrap, add hosts:

```bash
MINIKUBE_IP=$(minikube ip)
echo "$MINIKUBE_IP portal.local grafana.local" | sudo tee -a /etc/hosts
```

Access:

- Backstage: `http://portal.local`
- Grafana: `http://grafana.local` (default user `admin`)

## CI/CD and deployment

- `ci.yml`:
  - test sample services
  - lint + typecheck Backstage
  - build images
  - Trivy scan (fail on `HIGH`/`CRITICAL`)
  - push images to GHCR
- `deploy.yml`:
  - runs on self-hosted runner after CI success
  - deploys tagged images to Minikube
  - runs rollout + smoke checks

Set repository secrets:

- `GHCR_USERNAME`
- `GHCR_TOKEN`
- `BACKSTAGE_GITHUB_TOKEN`

## Build images locally

```bash
docker build -f docker/backstage-backend.Dockerfile -t backstage-backend:local .
docker build -f docker/backstage-frontend.Dockerfile -t backstage-frontend:local .
docker build -f services/service-catalog/Dockerfile -t service-catalog:local services/service-catalog
docker build -f services/service-identity/Dockerfile -t service-identity:local services/service-identity
```

## Demo runbook

Use [docs/runbook-demo.md](docs/runbook-demo.md) for the mandatory 10-step demo flow.

## Architecture diagram

Use [docs/architecture.md](docs/architecture.md) for report and presentation slides.

## Before vs after

Use [docs/before-after-comparison.md](docs/before-after-comparison.md) as slide/report material.

## VPS deployment by ZIP upload

On your local machine, create ZIP:

```bash
zip -r developer-portal-upload.zip . -x ".git/*" "node_modules/*" "backstage/node_modules/*"
```

Upload ZIP to VPS:

```bash
scp -P 24700 developer-portal-upload.zip root@<VPS_IP>:/root/
```

On VPS, deploy from uploaded ZIP:

```bash
mkdir -p /tmp/developer-portal-bootstrap
unzip -o /root/developer-portal-upload.zip -d /tmp/developer-portal-bootstrap
chmod +x /tmp/developer-portal-bootstrap/scripts/*.sh
/tmp/developer-portal-bootstrap/scripts/vps-deploy-from-zip.sh /root/developer-portal-upload.zip /opt/developer-portal
```

Enable auto-start after reboot:

```bash
/opt/developer-portal/scripts/install-vps-systemd.sh
```
