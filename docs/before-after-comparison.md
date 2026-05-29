# Before vs After Applying Developer Portal + DevSecOps

| Aspect | Before | After |
|---|---|---|
| Service ownership | Scattered across chat/docs | Centralized in Backstage Catalog |
| Technical docs | Separate files, hard to find | TechDocs from entity page |
| CI/CD visibility | Open each repo manually | CI/CD tab in Backstage entity |
| Kubernetes status | kubectl-only, low visibility | Kubernetes plugin in service page |
| Security scanning | Manual or not enforced | Trivy automated in CI |
| Code quality gate | Inconsistent | ESLint enforced in CI |
| Secret handling | Risk of plaintext | Kubernetes Secret + GitHub secrets |
| Access control | Broad cluster access | Read-only RBAC for portal |
| Monitoring | Limited ad hoc checks | Prometheus + Grafana dashboards |
| Incident triage | Slow, fragmented | Single portal + metrics + runtime status |
