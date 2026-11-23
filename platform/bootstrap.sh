#!/usr/bin/env bash
# Installs Argo CD into the current kubectl context and hands the cluster over to Git.
# Run once per cluster (k3d or the cloud VM); running it again is harmless.
#
#   ./platform/bootstrap.sh
#
# After this, everything is changed by commits to this repository, Argo CD itself included.
set -euo pipefail

cd "$(dirname "$0")"

# Single source of the version: the Argo CD Application that later manages the installation.
chart_version=$(sed -n '/chart: argo-cd/,/targetRevision:/ s/^ *targetRevision: *//p' apps/argocd.yaml)
[[ -n "$chart_version" ]] || { echo "argo-cd chart version not found in apps/argocd.yaml" >&2; exit 1; }

echo "Context: $(kubectl config current-context), Argo CD chart $chart_version"

helm upgrade --install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version "$chart_version" \
  --namespace argocd --create-namespace \
  --values argocd/values.yaml \
  --wait

kubectl apply -f root.yaml

echo
echo "Argo CD is syncing platform/apps. UI:"
echo "  kubectl -n argocd port-forward svc/argocd-server 8080:80   ->  http://localhost:8080"
echo "  user: admin, password:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
