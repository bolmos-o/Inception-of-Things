#!/bin/bash

# create cluster
k3d cluster create iot --network "host"
kubectl create namespace dev

helm repo add gitlab https://charts.gitlab.io/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# deploy gitlab
helm upgrade --install gitlab gitlab/gitlab \
  --create-namespace --namespace gitlab \
  --timeout 600s \
  --set global.hosts.domain=localhost \
  --set global.hosts.https=false \
  --set nginx-ingress.enabled=false \
  --set global.ingress.class=traefik \
  --set global.ingress.provider=traefik \
  --set certmanager-issuer.email=me@example.com \
  --set postgresql.image.tag=13.6.0 \
  --set gitlab-runner.install=false \
  --set global.edition=ce

# deploy argocd
helm install argocd argo/argo-cd \
  --create-namespace --namespace argocd \
  --set repoServer.dnsPolicy=ClusterFirstWithHostNet \
  --set repoServer.hostNetwork=true

# port-foward argocd
echo "Waiting for argocd server"
kubectl wait --for=condition=Ready pod/$(kubectl get pods -n argocd | grep argocd-server | awk '{print $1}') --timeout=300s -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443 >> ~/argocd-log.txt 2>&1 &

# change argocd password to "inception"
echo "Logging in and setting argocd password."
argocd login localhost:8080 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd account update-password --current-password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo) --new-password inception

echo "Creating repository in GitLab"
kubectl wait --for=condition=Ready pod/$(kubectl get pods -n gitlab | grep -m1 webservice | awk '{print $1}') --timeout=300s -n gitlab
gitlabPassword=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo)
gitlabRepoPath=http://root:$gitlabPassword@gitlab.localhost/root/bolmos-o.git
git clone https://github.com/bolmos-o/bolmos-o
cd bolmos-o && git push --set-upstream $gitlabRepoPath

# deploy app
kubectl config set-context --current --namespace=argocd
argocd app create app --repo $gitlabRepoPath --path iot --dest-server https://kubernetes.default.svc --dest-namespace dev
argocd app set app --sync-policy automated
argocd app sync app