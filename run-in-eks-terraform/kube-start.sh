#!/bin/zsh

set -e
cd "$(dirname "$0")"

pushd "terraform"
terraform init
terraform apply
terraform output kubeconfig > ../.kubeconfig
popd

export KUBECONFIG=$(pwd)/.kubeconfig
