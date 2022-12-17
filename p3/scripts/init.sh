#!/bin/bash

# install Mozilla (default browser does not work)
sudo apt install -y firefox-esr

# install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# install k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# create cluster
sudo k3d cluster create mycluster -p 8080:80@loadbalancer -p 8888:8888@loadbalancer
sudo kubectl create namespace argocd
sudo kubectl create namespace dev

# deploy argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#need for argocd
sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

#playground
sudo kubectl apply -f ../confs/app.yml -n dev

#argocd password
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

#argocd login - admin


