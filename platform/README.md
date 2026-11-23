# Platform

Cluster add-ons shared by all environments, delivered by Argo CD from this directory.

```text
root.yaml                     # the only manifest applied by hand (bootstrap.sh): syncs apps/
apps/
├── argocd.yaml               # Argo CD manages its own installation (chart version here)
├── sealed-secrets.yaml       # Sealed Secrets controller in kube-system (ADR-0019)
├── ticketflow-project.yaml   # AppProject: services only from our repos, only into qa / prod
└── services.yaml             # ApplicationSet: one Application per environments/<env>/<service>/values.yaml
argocd/values.yaml            # Argo CD settings
bootstrap.sh                  # installs Argo CD and applies root.yaml
```

## New cluster

Tools: `mise install` (Helm and kubectl, pinned in `mise.toml`). With `kubectl` pointing at the
cluster (`k3d-ticketflow` locally):

```bash
./platform/bootstrap.sh
```

Argo CD installs itself from Helm, then syncs everything else from `main` of this repository:
Sealed Secrets, the `ticketflow` project, and the services in `qa` and `prod`.

## UI

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
kubectl -n argocd port-forward svc/argocd-server 8080:80        # keeps running; http://localhost:8080
```

`port-forward` holds the terminal until Ctrl+C, so it goes last (or into its own terminal).

User `admin`. Change the password after the first login, then delete `argocd-initial-admin-secret`.

## Rules

- After the bootstrap, **do not use `helm` or `kubectl apply` on anything managed here** — change
  the files and merge. Manual changes in the cluster are reverted (self-heal).
- Upgrading Argo CD or Sealed Secrets = changing `targetRevision` in its Application.
