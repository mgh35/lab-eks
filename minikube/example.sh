#!/bin/zsh

set -e
cd "$(dirname "$0")"

kubectl apply -f ../application/hello-world.yaml

kubectl run -i --tty busybox --image=busybox --restart=Never -- sh
