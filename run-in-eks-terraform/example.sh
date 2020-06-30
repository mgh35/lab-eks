#!/bin/zsh

set -e
cd "$(dirname "$0")"

NAMESPACE=hello

kubectl apply -f cluster/namespace.yaml
kubectl apply -f cluster/service-world.yaml

kubectl exec \
  -it $(kubectl get pods -n $NAMESPACE -o json | jq '.items[0].metadata.name' -r) \
  -n $NAMESPACE \
  -- \
  wget -q -O - http://world:5000/world
