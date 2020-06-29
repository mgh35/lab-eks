#!/bin/zsh

set -e
cd "$(dirname "$0")"

CLUSTER=lab-eks
NAMESPACE=hello



################################
# Setup Fargate for Worker Nodes

eksctl create fargateprofile \
  --cluster $CLUSTER \
  --name $NAMESPACE \
  --namespace $NAMESPACE



##########
# Services

kubectl apply -f cluster/namespace.yaml

kubectl apply -f cluster/service-world.yaml
kubectl apply -f cluster/service-nemesis.yaml

#kubectl run cmd-in-cluster -n $NAMESPACE --image=busybox --attach=true --restart=Never --rm -- wget -q -O - http://world:5000/world
kubectl exec -it $(kubectl get pods -n $NAMESPACE -o json | jq '.items[0].metadata.name' -r) -n $NAMESPACE -- wget -q -O - http://world:5000/world



#########
# Ingress

kubectl apply -f cluster/ingress.yaml

kubectl get ingress -n $NAMESPACE

HOST=$(kubectl get ingress -n $NAMESPACE -o json | jq '.items[0].status.loadBalancer.ingress[0].hostname' -r)
wget -O - http://$HOST/world

# Debug ingress

kubectl logs -n kube-system deployment.apps/alb-ingress-controller

LOADBALANCER_PREFIX=$(kubectl get ingress ingress -n $NAMESPACE -o json | jq -r '.status.loadBalancer.ingress[0].hostname' | cut -d- -f1)
while read -r ARN
do
  printf "%s\n" "$ARN"
  aws elbv2 describe-target-health --target-group-arn "$ARN" | jq -r '.TargetHealthDescriptions[].TargetHealth.State'
  printf "\n\n"
done <<< "$(aws elbv2 describe-target-groups | jq -r '.TargetGroups[].TargetGroupArn' | grep $LOADBALANCER_PREFIX)"
