#!/bin/zsh

set -e
cd "$(dirname "$0")"

PROFILE=lab-eks
REGION=us-east-2
CLUSTER=lab-eks

eksctl create cluster \
  --name $CLUSTER \
  --version 1.16 \
  --profile $PROFILE \
  --region $REGION \
  --fargate

#kubectl config current-context

CLUSTER_INFO=$(aws eks describe-cluster \
  --profile $PROFILE \
  --region $REGION \
  --name $CLUSTER)

VPC=$(echo $CLUSTER_INFO | jq '.cluster.resourcesVpcConfig.vpcId' -r)

################
# Setup for ALB

eksctl utils associate-iam-oidc-provider \
  --profile $PROFILE \
  --region $REGION \
  --cluster $CLUSTER \
  --approve

# Saved to repo 2020-06-27
# curl -o policies/iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json
ALB_POLICY_CREATE=$(aws iam create-policy \
    --profile $PROFILE \
    --policy-name ALBIngressControllerIAMPolicy \
    --policy-document file://policies/iam-policy.json)
ALB_POLICY_ARN=$(echo $ALB_POLICY_CREATE | jq '.Policy.Arn' -r)

# Saved to repo 2020-06-27
# curl -o cluster/rbac-role.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
kubectl apply -f cluster/rbac-role.yaml

eksctl create iamserviceaccount \
    --profile $PROFILE \
    --region $REGION \
    --name alb-ingress-controller \
    --namespace kube-system \
    --cluster $CLUSTER \
    --attach-policy-arn $ALB_POLICY_ARN \
    --override-existing-serviceaccounts \
    --approve

# Saved to repo 2020-06-27
# curl -o cluster/alb-ingress-controller.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml
yq w -i cluster/alb-ingress-controller.yaml -- 'spec.template.spec.containers[0].args[+]' "--cluster-name=$CLUSTER"
yq w -i cluster/alb-ingress-controller.yaml -- 'spec.template.spec.containers[0].args[+]' "--aws-region=$REGION"
yq w -i cluster/alb-ingress-controller.yaml -- 'spec.template.spec.containers[0].args[+]' "--aws-vpc-id=$VPC"
yq w -i cluster/alb-ingress-controller.yaml -- 'spec.template.spec.containers[0].image' "docker.io/amazon/aws-alb-ingress-controller:v1.1.6"
kubectl apply -f cluster/alb-ingress-controller.yaml
