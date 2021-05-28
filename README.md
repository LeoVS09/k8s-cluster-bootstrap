# Kubernetes Infrustructure Bootstrap

Defaults infrastructure services bootstrap for new k8s clusters.

It define basic infrustructure services, which can be usefull for newly created cluster.
You can fork this project for define your own infrsutructure bootstrap.
Don't mix infrustructure and business services, this setup only define basic infrsutructure,
for define business services better use GitOps soltuions, like [ArgoCD](https://argoproj.github.io/argo-cd/).

## Requirements

Create kubernetes cluster version `1.21.*`, newer version not working with kubernetes dashboard, update it in file if you using 1.22 or newer.
configure [kubectl](https://kubernetes.io/docs/tasks/tools/) for connect to cluster.

Install:

* [Helm](https://helm.sh/) - The package manager for Kubernetes
* [Hemlile](https://github.com/roboll/helmfile) - Deploy Kubernetes Helm Charts

clone repository

## Services

Current setup contains:

* [Kubernetes Dashboard](https://github.com/kubernetes/dashboard) - General-purpose web UI for Kubernetes clusters

## Usage

For setup basic infrustructure run

```bash
helmfile sync
```

### if you using minikube

Enable minikkube ingress before sync, by next command

```bash
make minikube-ingress 
```

After that run sync, and get external ip

```bash
make minikube-ip
```

And add to `/etc/hosts` file next line

```
<your-external-ip> k8s.local
```

## For Access Kubernetes Dashboard

get authentication token

```bash
# list existing secrets
kubectl -n kubernetes-dashboard get secrets
# pass correct name of secret
kubectl -n kubernetes-dashboard describe secret kubernetes-dashboard-token-<some-id>
# copy token
```

### Though Ingress

open <https://k8s.local> and pass copied token

### Through proxy

create local proxy

```bash
kubectl proxy
```

open <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:https/proxy/>
and pass copied token
