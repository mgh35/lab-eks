#!/bin/zsh

set -e
cd "$(dirname "$0")"

DIR=cluster/

kubectl apply -f $DIR

kubectl get all
kubectl run cmd-in-cluster --image=busybox --attach=true --restart=Never --rm -- wget -q -O - http://hello-world:5000

INGRESS_IP=$(kubectl get ingress ingress -o json | jq '.status.loadBalancer.ingress[0].ip' -r)
wget -q -O - http://$INGRESS_IP/world

kubectl delete -f $DIR
