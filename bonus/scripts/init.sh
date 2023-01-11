#!/bin/bash

# create cluster
k3d cluster create iot --host-alias 172.20.0.2:gitlab.example.com --k3s-arg="--disable=traefik@server:0" -p 443:443@loadbalancer #-p 8888:8888@loadbalancer 
kubectl create namespace argocd
kubectl create namespace dev

#installing gitlab with helm
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --create-namespace --namespace gitlab \
  --timeout 600s \
  --set global.hosts.domain=example.com \
  --set certmanager-issuer.email=me@example.com \
  --set postgresql.image.tag=13.6.0 \
  --set global.edition=ce

# deploy argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# install argocd cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo "Waiting for argocd server"
# port-foward argocd
kubectl get all -n argocd
kubectl wait --for=condition=Ready pod/$(kubectl get pods -n argocd | grep argocd-server | awk '{print $1}') --timeout=300s -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443 >> ~/argocd-log.txt 2>&1 &

echo "Logging and setting argocd password."
# change argocd password
argocd login localhost:8080 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd account update-password --current-password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo) --new-password inception

echo "Getting gitlab password:"
# get gitlab secret (might have to wait, need testing)
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

# here we should restore gitlab with toolbox. the backup is yet to be done.
# reference: https://docs.gitlab.com/charts/backup-restore/

# # deploy app
kubectl config set-context --current --namespace=argocd
argocd app create app --repo https://gitlab.example.com/root/bolmos-o.git --path iot --dest-server https://kubernetes.default.svc --dest-namespace dev
# argocd app sync app

# argocd app set app --sync-policy automated