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




## EKS




## References

### Kubernetes

https://kubernetes.io/

### EKS

https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

https://www.weave.works/technologies/kubernetes-on-aws/

https://aws.amazon.com/fargate/

### EKS with Terraform

https://aws.amazon.com/blogs/startups/from-zero-to-eks-with-terraform-and-helm/

https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster

https://github.com/hashicorp/learn-terraform-provision-eks-cluster

