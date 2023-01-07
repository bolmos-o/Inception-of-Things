#!/bin/bash

# create cluster
k3d cluster create iot -p 8080:443@loadbalancer -p 8888:8888@loadbalancer --k3s-arg="--disable=traefik@server:0"
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

#installing gitlab with helm
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab --namespace gitlab \
  --timeout 600s \
  --set global.hosts.domain=iot \
  --set certmanager-issuer.email=me@example.com \
  --set postgresql.image.tag=13.6.0

# set up hosts and get gitlab password
sudo sh -c "echo `kubectl get svc -n gitlab | grep LoadBalancer | awk '{print $4}'` gitlab.iot >> /etc/hosts"

# have to wait, otherwise the service is not up
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

# # deploy argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# # install argocd cli
# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
# rm argocd-linux-amd64

# # login. new password: inception
# while [ $(curl -s -o /dev/null localhost:8080; echo $?) -gt 0 ]; do
# 	echo "Waiting for argocd..."
# 	sleep 5
# done
# argocd login localhost:8080 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
# argocd account update-password --current-password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo) --new-password inception


# # deploy app
# kubectl config set-context --current --namespace=argocd
# argocd app create app --repo gitlab.iot --path iot --dest-server https://kubernetes.default.svc --dest-namespace dev
# argocd app sync app

# argocd app set app --sync-policy automated

