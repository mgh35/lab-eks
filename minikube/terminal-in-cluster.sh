#!/bin/zsh

kubectl run -i --tty terminal-in-cluster --image=ubuntu:18.04 --restart=Never -- /bin/bash
kubectl delete pods terminal-in-cluster
