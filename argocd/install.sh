#!/usr/bin/env bash
# ArgoCD bootstrap — run once on the k3s node
# Usage: bash argocd/install.sh

set -euo pipefail

ARGOCD_VERSION="v2.14.11"

echo "▶ Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "▶ Installing ArgoCD ${ARGOCD_VERSION}..."
kubectl apply -n argocd -f \
  "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo "▶ Patching argocd-server to disable TLS (Traefik handles it)..."
kubectl patch deployment argocd-server -n argocd \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}]'

echo "▶ Applying Traefik Ingress for ArgoCD UI..."
kubectl apply -f argocd/ingress.yaml

echo "▶ Applying ArgoCD Application..."
kubectl apply -f argocd/application.yaml

echo ""
echo "✅ ArgoCD installed."
echo ""
echo "Initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "UI: https://argocd.daengglejeju.cloud"
