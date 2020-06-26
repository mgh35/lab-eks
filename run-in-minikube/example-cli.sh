#!/bin/zsh

set -e
cd "$(dirname "$0")"

kubectl create deployment hello-world --image=mgh35/hello-world:0.1.0
kubectl run

POD=$(kubectl get pods | grep hello-world | cut -d' ' -f1)
kubectl exec -it $POD -- wget -q -O - http://localhost:5000

kubectl run cmd-in-cluster --image=busybox --attach=true --restart=Never --rm -- wget -q -O - http://hello-world:5000


####################################
# Expose the service in the cluster

kubectl expose deployment hello-world --type=ClusterIP --port=5000 --target-port=5000

kubectl run cmd-in-cluster --image=busybox --attach=true --restart=Never --rm -- wget -q -O - http://hello-world:5000

kubectl delete service hello-world


###################################################
# Expose the service outside the cluster - NodePort

kubectl expose deployment hello-world --type=NodePort --port=5000

kubectl run cmd-in-cluster --image=busybox --attach=true --restart=Never --rm -- wget -q -O - http://hello-world:5000

NODEIP=$(kubectl get nodes minikube -o json | jq '.status.addresses[] | select(.type == "InternalIP").address' -r)
NODEPORT=$(kubectl get service hello-world -o json | jq '.spec.ports[0].nodePort')
wget -q -O - http://$NODEIP:$NODEPORT

kubectl delete service hello-world

#######################################################
# Expose the service outside the cluster - LoadBalancer

kubectl expose deployment hello-world --type=LoadBalancer --port=5000

kubectl run cmd-in-cluster --image=busybox --attach=true --restart=Never --rm -- wget -q -O - http://hello-world:5000

# minikube doesn't natively support a LoadBalancer. There's a dev work-around:
#
#  > minikube tunnel
#
# run from a separate terminal.

LOADBALANCER=$(kubectl get service hello-world -o json | jq '.status.loadBalancer.ingress[0].ip' -r)

wget -q -O - http://$LOADBALANCER:5000

kubectl delete service hello-world


###########
#  DONE

kubectl delete all --all
