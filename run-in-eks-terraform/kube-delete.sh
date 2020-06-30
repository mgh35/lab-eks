#!/bin/zsh

set -e
cd "$(dirname "$0")"

kubectl delete -f cluster/ --wait=true

pushd "terraform"
terraform destroy
popd

unset KUBECONFIG
