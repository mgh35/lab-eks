#!/bin/zsh

set -e
cd "$(dirname "$0")"

CLUSTER=lab-eks

kubectl delete -f cluster/

eksctl delete fargateprofile \
  --cluster $CLUSTER \
  --name hello-world

kubectl delete -f cluster-setup/

eksctl delete iamserviceaccount \
  --name alb-ingress-controller \
  --namespace kube-system \
  --cluster $CLUSTER

aws iam delete-policy --policy-arn $(aws iam list-policies | jq '.Policies[] | select(.PolicyName == "ALBIngressControllerIAMPolicy") | .Arn' -r)

eksctl delete cluster \
  --name $CLUSTER
