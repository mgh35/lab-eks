#!/bin/zsh

set -e
cd "$(dirname "$0")"

CLUSTER=lab-eks
ALB_VERSION=v1.1.6

#aws configure

eksctl create cluster \
  --name $CLUSTER \
  --fargate

#kubectl config current-context

CLUSTER_INFO=$(aws eks describe-cluster --name $CLUSTER)

VPC=$(echo $CLUSTER_INFO | jq '.cluster.resourcesVpcConfig.vpcId' -r)



################
# Setup for ALB

eksctl utils associate-iam-oidc-provider \
  --cluster $CLUSTER \
  --approve

curl -o policies/alb-ingress-controller.json "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/$ALB_VERSION/docs/examples/iam-policy.json"
ALB_POLICY_CREATE=$(aws iam create-policy \
    --policy-name ALBIngressControllerIAMPolicy \
    --policy-document file://policies/alb-ingress-controller.json)
ALB_POLICY_ARN=$(echo $ALB_POLICY_CREATE | jq '.Policy.Arn' -r)

curl -o cluster-setup/rbac-role.yaml "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/$ALB_VERSION/docs/examples/rbac-role.yaml"
kubectl apply -f cluster-setup/rbac-role.yaml

eksctl create iamserviceaccount \
    --name alb-ingress-controller \
    --namespace kube-system \
    --cluster $CLUSTER \
    --attach-policy-arn "$ALB_POLICY_ARN" \
    --override-existing-serviceaccounts \
    --approve

curl -o cluster-setup/alb-ingress-controller.yaml "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/$ALB_VERSION/docs/examples/alb-ingress-controller.yaml"
yq w -i cluster-setup/alb-ingress-controller.yaml -- 'spec.template.spec.containers[0].args[+]' "--cluster-name=$CLUSTER"
yq w -i cluster-setup/alb-ingress-controller.yaml -- 'spec.template.spec.containers[0].args[+]' "--aws-region=$(aws configure list | grep region | awk '{print $2}')"
yq w -i cluster-setup/alb-ingress-controller.yaml -- 'spec.template.spec.containers[0].args[+]' "--aws-vpc-id=$VPC"
kubectl apply -f cluster-setup/alb-ingress-controller.yaml
