#!/bin/zsh

set -e
cd "$(dirname "$0")"

DIR=../cluster/

kubectl apply -f $DIR

kubectl get all

kubectl run cmd-in-cluster --image=busybox --attach=true --restart=Never --rm -- wget -q -O - http://hello-world:5000

kubectl delete -f $DIR
