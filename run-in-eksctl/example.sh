#!/bin/zsh

set -e
cd "$(dirname "$0")"

PROFILE=lab-eks
REGION=us-east-2
CLUSTER=lab-eks
NAMESPACE=hello-world

eksctl create fargateprofile \
  --profile $PROFILE \
  --region $REGION \
  --cluster $CLUSTER \
  --name hello-world \
  --namespace $NAMESPACE

kubectl apply -f cluster/hello-world-namespace.yaml

kubectl apply -f cluster/hello-world-deployment.yaml
kubectl apply -f cluster/hello-world-service.yaml

kubectl apply -f cluster/hello-nemesis-deployment.yaml
kubectl apply -f cluster/hello-nemesis-service.yaml

kubectl apply -f cluster/hello-world-ingress.yaml

kubectl get ingress -n hello-world
#kubectl logs -n kube-system deployment.apps/alb-ingress-controller

HOST=$(kubectl get ingress -n hello-world -o json | jq '.items[0].status.loadBalancer.ingress[0].hostname' -r)
wget -O - http://$HOST/world