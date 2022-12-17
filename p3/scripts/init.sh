#!/bin/bash

# create cluster
k3d cluster create iot -p 8080:443@loadbalancer -p 8888:8888@loadbalancer
kubectl create namespace argocd
kubectl create namespace dev

# deploy argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# install argocd cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64


# login. new password: inception
while [ $(curl -s -o /dev/null localhost:8080; echo $?) -gt 0 ]; do
	echo "Waiting for argocd..."
	sleep 5
done
argocd login localhost:8080 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd account update-password --current-password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo) --new-password inception

# deploy app
kubectl config set-context --current --namespace=argocd
argocd app create app --repo https://github.com/bolmos-o/bolmos-o --path iot --dest-server https://kubernetes.default.svc --dest-namespace dev
argocd app sync app

argocd app set app --sync-policy automated
