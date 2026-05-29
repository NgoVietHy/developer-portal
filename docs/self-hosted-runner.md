# Self-hosted Runner for Minikube Deploy

`deploy.yml` requires a self-hosted GitHub Actions runner with direct access to `kubectl` and `minikube`.

## Setup steps (Ubuntu 22.04)

1. Create runner in GitHub repository settings (`Settings -> Actions -> Runners`).
2. Install runner binary and register it on the Minikube host.
3. Install required tools on runner host:
   - `docker`
   - `kubectl`
   - `minikube`
   - `helm`
4. Ensure runner labels include:
   - `self-hosted`
   - `linux`
   - `x64`
5. Ensure kube context points to the target Minikube cluster:
   ```bash
   kubectl config current-context
   ```
6. Verify deploy prerequisites:
   ```bash
   kubectl get nodes
   kubectl -n developer-portal get all
   ```

## Required repository secrets

- `GHCR_USERNAME`
- `GHCR_TOKEN`
- `BACKSTAGE_GITHUB_TOKEN`
