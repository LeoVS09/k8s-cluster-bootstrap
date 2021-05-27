# Kubernetes Infrustructure Bootstrap

It is default bootstrap temaplte for new k8s cluster.
It define basic infrustructure services, which can be usefull for newly created cluster.
You can fork this project for define your own infrsutructure bootstrap.
Don't mix infrustructure and business services, this setup only define basic infrsutructure,
for define business services better use GitOps soltuions, like [ArgoCD](https://argoproj.github.io/argo-cd/).

## Requirements

Create kubernetes cluster and configure [kubectl](https://kubernetes.io/docs/tasks/tools/) for connect to cluster.

Install:

* [Helm](https://helm.sh/) - The package manager for Kubernetes
* [Hemlile](https://github.com/roboll/helmfile) - Deploy Kubernetes Helm Charts

clone repository

## Usage

For setup basic infrustructure run

```bash
helmfile sync
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

create local proxy

```bash
kubectl proxy
```

open <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>
and pass cpoied token
