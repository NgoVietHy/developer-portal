# Demo Runbook (Mandatory Items)

## 1) Truy cap Developer Portal

- Open `http://portal.local`
- Sign in with Guest provider

## 2) Xem danh sach service trong Software Catalog

- Navigate `Catalog`
- Verify entities:
  - `developer-portal`
  - `service-catalog`
  - `service-identity`

## 3) Mo TechDocs

- Open entity `service-catalog`
- Select `Docs` tab

## 4) Xem repository GitHub

- In entity metadata links, open GitHub repository annotation (`github.com/project-slug`)

## 5) Xem trang thai CI/CD

- Open entity `service-catalog`
- Select `CI/CD` tab (GitHub Actions plugin)

## 6) Xem Kubernetes workloads

- Open entity `service-catalog`
- Select `Kubernetes` tab
- Verify pod/deployment/service status

## 7) Chay pipeline build + deploy

- Trigger GitHub Actions `CI` on push
- Verify `Deploy to Minikube` workflow runs after CI success

## 8) Chay scan bao mat Trivy

- In `CI` workflow, verify Trivy scan step passes for all images

## 9) Mo Grafana dashboard

- Open `http://grafana.local`
- Verify dashboard `Developer Portal Overview`

## 10) Trinh bay so sanh truoc/sau

- Use table from `docs/before-after-comparison.md`
