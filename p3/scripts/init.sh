#!/bin/bash

# create cluster
k3d cluster create iot -p 8080:443@loadbalancer -p 8888:8888@loadbalancer
kubectl create namespace argocd
kubectl create namespace dev

# deploy argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# login. new password: inception
echo "Waiting for argocd..."
kubectl wait --for=condition=Ready pod/$(kubectl get pods -n argocd | grep argocd-server | awk '{print $1}') --timeout=300s -n argocd
argocd login localhost:8080 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd account update-password --current-password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo) --new-password inception

# deploy app
kubectl config set-context --current --namespace=argocd
argocd app create app --repo https://github.com/bolmos-o/bolmos-o --path iot --dest-server https://kubernetes.default.svc --dest-namespace dev
argocd app set app --sync-policy automated
argocd app sync app
