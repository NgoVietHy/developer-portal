# Kubernetes manifests

- `base/`: common resources for namespace, postgres, backstage, sample services, RBAC, and monitoring ServiceMonitors
- `overlays/minikube/`: Minikube-specific overlay

Apply manually:

```bash
kubectl apply -k k8s/overlays/minikube
```
