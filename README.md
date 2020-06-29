# EKS

The purpose of this lab is to setup a basic Kubernetes cluster on AWS.

## Kubernetes

[A summary. For details see [kubernetes.io](https://kubernetes.io/).]

### Overview

Kubernetes is platform for orchestrating containerized services.

Kubernetes [provides](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/#why-you-need-kubernetes-and-what-can-it-do):
- Service discovery and load balancing
- Storage orchestration
- Automated rollouts and rollbacks
- Automatic bin packing
- Self-healing
- Secret and configuration management

### Components

#### Control Plane

This is the heart of Kubernetes. This is the part of the system responsible for maintaining the cluster in the desired 
state and managing interactions.

It consists of services:

- kube-apiserver: Exposes the Kubernetes API
- etcd: Key-value store used as the backing store for cluster data.
- kube-scheduler: Responsible for scheduler pods that don't yet have a worker.
- kube-controller-manager: (Collection of Controllers collected in a single binary)
    - Node Controller: Watch for nodes that go down
    - Replication Controller: Maintain the correct number of pods
    - Endpoints Controller: Populate Endpoints object
    - Service Account & Token Controller: Create default accounts & access tokens
- cloud-controller-manager: (Only if connecting to a cloud) Talks to the cloud API

These are typically deployed on a single host, which is typically separate from the other nodes. For added resiliency, 
it can also be replicated across multiple hosts (or individual components of it can be).

#### Worker Node

These are the nodes where the containers are run. 

These nodes thus require a container runtime. These [should have](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-node/container-runtime-interface.md) 
a Kubernetes Container Runtime Interface (CRI) implementation. Docker the common choice here.

In addition, there are a couple services needed for Kubernetes to manage the worker:

- kubelet: Responsible for creating and managing pods created on that node.
- kube-proxy: Responsible for network rules on the node.

### API

Kubernetes is based around a declarative API which specifies the desired state of the cluster. The Kubernetes services 
are then responsible to continually monitor the cluster and bring it back towards the desired state as needed.

This consists of a set of Objects. Each Object has a:

- spec: Definiton of the desired state.
- status: A description of the current state.

The Spec is set by the user. The Status is continually updated by services in the Control Plane. Where there's a diff, 
services in the Control Plane work to move it towards the Spec.

Some key Objects making up the Kubernetes API:

#### Node

This represents a worker node. It is some host on which containers can be run.

#### Pod

This is the smallest unit of something to be run in Kubernetes. This should be the simplest unit of an application and 
the level at which it can be scaled horizontally.

At its simplest, it is one container running on some Node. 

In general, it can actually be multiple containers running on the same Node and sharing resource (eg storage). This 
allows for "sidecar" type services related to the main service. For example if every instance of the application has a 
service pushing the logs from local disk to a log aggregation service, that could run as a separate container in the 
same Pod. But note that the intent is to use this only with tightly-coupled containers that act as a cohesive unit, and
it is the responsibility of the developer to maintain that.

#### PodTemplate

A Pod itself is ephemeral - if it crashes, it won't be recreated. Higher-level abstractions handle that persistence. To
be able to create instances of Pods, they can use a PodTemplate.

#### Controllers

These manage the lifecycle of a service. Details [here](https://kubernetes.io/docs/concepts/workloads/controllers/).

Examples:
- Deployment: Manage a replicated set of Pods over the cluster with handling for controlled changes.
- DaemonSet: Manage a daemon service that should exist once on every Node.
- Job: Manage a workflow that should run once, with handling of failures.
- CronJob: Manage a job that should run on a given schedule

#### Service

A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) is an abstraction around an 
interchangeable collection of Pods that adds support for things like discovery and load-balancing.

There are 3 types of Service Type:

- ClusterIP: Only visible within the cluster.
- NodePort: Exposes a port (in the range 30000–32767) on every Node in the cluster. Mainly debugging tool.
- LoadBalancer: A load balancer for the Service will be created.

#### Ingress

An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) manages access to Services in the cluster
from outside the cluster. It is a separate Service that can route traffic to multiple different services.

This [solves](https://itnext.io/kubernetes-clusterip-vs-nodeport-vs-loadbalancer-services-and-ingress-an-overview-with-722a07f3cfe1) 
a number of limitations of the LoadBalancer Services:
- A single IP can route to multiple services
- No need to run & pay for multiple load balancers
- Level 7 routing

#### Volume

A [Volume](https://kubernetes.io/docs/concepts/storage/volumes/) is an abstraction around storage. 

More than the "Volume" in Docker, a Kubernetes Volume includes a lifetime which can exceed that of the containers.

There are a number of backends that can host the storage. And there is a concept of 
[PersistentVolume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) where required.

#### ConfigMap

A [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) is a key-value store for non-sensitive 
configuration information.

This can be used, eg, in other object Specs (which manages the appropriate triggers on changes), like:

```yaml
...
      env:
        # Define the environment variable
        - name: PLAYER_INITIAL_LIVES # Notice that the case is different here
                                     # from the key name in the ConfigMap.
          valueFrom:
            configMapKeyRef:
              name: game-demo           # The ConfigMap this value comes from.
              key: player_initial_lives # The key to fetch.
...
```

#### Secret

[Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) are a mechanism to manage sensitive data (eg 
passwords) in the cluster.

### Notes

- Kubernetes doesn't (necessarily) use the Docker daemon of the system Docker instance.
    - With minikube, eg, you can use minikube's Docker daemon with `eval $(minikube docker-env)`
- Per [here](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#service-v1-core), the Service.selector 
    matches on key-value Label pairs.
- See system services with: `kubectl get pods -n kube-system`
- [Add ingress](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/) to minikube with addon: 
    `minikube addons enable ingress`

## EKS

Elastic Kubernetes Service (EKS) is Amazon's managed Kubernetes services. 

It provides a working and up-to-date Control Plane implementation on top of AWS services, with a few options for Worker 
Nodes. Once up, it can be connected to with kubectl as usual.

### Components

#### Network

The kubernetes' cluster network in EKS is implemented via AWS VPCs. One managed VPC is setup for the control plane and
another VPC is setup for the Worker Nodes.

There are a [variety](https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/)
of ways to configure this depending on how you want the network to be. Particularly, there are options to keep these 
either public or private.

#### Worker Nodes

Worker nodes can be run on:
- EC2 instances
- [AWS Fargate](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html) (a serverless container execution service)

### Setup

Per [here](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html), the recommended ways to setup an EKS
instance are:
- AWS Console
- `eksctl` CLI

Using `eksctl`, it creates the components in a CloudFormation template. So you can use the CloudFormation console to see
the stack and its current state.

When [deleting](https://aws.amazon.com/premiumsupport/knowledge-center/eks-delete-cluster-issues/) the cluster, you want
to use the same tool used to create it to make sure it deletes the right pieces in the right order. With `eksctl`, it 
seems that since it builds itself in CloudFormation it's possible to handle the deletion through CloudFormation as well 
if there are problems using `eksctl` itself.

### Notes

- Using ALB with Fargate requires [ALB version > 1.1.4](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/issues/1097).
- Using ALB with `eksctl` has [issues if ALB > 1.1.6 but `eksctl` older](https://github.com/weaveworks/eksctl/pull/2068).
- Make sure to use the ingress controller configs for the relevant ALB version (as the required perms, eg, have changed).
- When using Fargate, make sure to use [ip mode](https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/)
    for the target type. This requires the services to have the `alb.ingress.kubernetes.io/target-type` annotation.
- Health checks are configured via the [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request)
    on the Pod spec.



## References

### Kubernetes

https://kubernetes.io/

https://kubernetes.io/blog/2015/10/some-things-you-didnt-know-about-kubectl_28/

https://kubernetes.io/docs/reference/kubectl/cheatsheet/

https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0

https://itnext.io/kubernetes-clusterip-vs-nodeport-vs-loadbalancer-services-and-ingress-an-overview-with-722a07f3cfe1

### EKS

https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

https://www.weave.works/technologies/kubernetes-on-aws/

https://aws.amazon.com/fargate/

https://aws.amazon.com/about-aws/whats-new/2020/05/introducing-amazon-eks-best-practices-guide-for-security/

https://aws.amazon.com/premiumsupport/knowledge-center/eks-delete-cluster-issues/

https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/

### EKS ALB

https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html

https://aws.amazon.com/blogs/containers/using-alb-ingress-controller-with-amazon-eks-on-fargate/

https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/

### EKS with Terraform

https://aws.amazon.com/blogs/startups/from-zero-to-eks-with-terraform-and-helm/

https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster

https://github.com/hashicorp/learn-terraform-provision-eks-cluster

