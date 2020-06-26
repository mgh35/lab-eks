#!/bin/zsh

ID=$(cat /dev/urandom | base64 | tr -dc '0-9a-z' | head -c8)
kubectl run -it terminal-in-cluster-$ID --image=busybox --restart=Never --rm
