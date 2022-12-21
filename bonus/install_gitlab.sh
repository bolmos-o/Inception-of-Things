#install helm
sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#gitlab namespace
sudo kubectl create namespace gitlab

#installing gitlab with helm
sudo helm repo add gitlab https://charts.gitlab.io/
sudo helm repo update

# https://docs.gitlab.com/charts/installation/deployment.html
# Guide for gitlab deployment using helm

helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@example.com \
  --set postgresql.image.tag=13.6.0
