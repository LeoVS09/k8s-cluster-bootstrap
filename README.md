# Kubernetes Infrustructure Bootstrap

Defaults services collection for production ready Kubernetes cluster.

This collection based on know enterprise wide services, already used by many companies.

If you searching for base setup for your cluster, probably [Bitnami Kubernetes Production Runtime](https://github.com/bitnami/kube-prod-runtime) will be usefull to you. Bitnamic alredy accessable for GKE, AKS, and Amazon EKS. But goal of this bootstrap define vendor free bootstrap, which can be started in any type of cluster, not depend on cloud provider.

You can fork this project for define your own infrsutructure bootstrap. Any PRs are allways welcome.
Don't mix infrustructure and business services, this setup only define basic infrsutructure,
for define business services better use GitOps soltuions, like [ArgoCD](https://argoproj.github.io/argo-cd/).

## Services

Current setup contains:

* [Kubernetes Dashboard](https://github.com/kubernetes/dashboard) - General-purpose web UI for Kubernetes clusters
* [Cert-Manager](https://github.com/jetstack/cert-manager) - Automatically provision and manage TLS certificates in Kubernetes
* [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack) - kube-prometheus-stack collects Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.

## Requirements

Create kubernetes cluster version and configure [kubectl](https://kubernetes.io/docs/tasks/tools/) for connect to it.

Install CLIs:

* [Helm](https://helm.sh/) - The package manager for Kubernetes.
* [Hemlile](https://github.com/roboll/helmfile) - One file for manage multiple heml charts.
* [GNU Make](https://www.gnu.org/software/make/manual/make.html) - install by `sudo apt-get install build-essential`

## Usage

For setup basic infrustructure run

```bash
# Will deply services and link roles for them
make sync
```

### Setup certificates

For use https you need setup sertificates, you can do it by next commands

```bash
# Will be used by lets encrypt for send emails about certificate updates
export CERTIFICATE_EMAIL=user@email.com
# Will create issuers (certificate providers)
make certificate-issuers
```

if `make sync`  were made first time in cluster wait some time before setup certificates,
k8s need time for load certificate manager operator

More about [ceertificate configuration](https://cert-manager.io/docs/configuration/acme/)
and [tutorial](https://cert-manager.io/docs/tutorials/acme/ingress/) for lets encrypt

**IMPORTANT:** If you not setup sertificates or setup them incorrectly, Ingresses will fallback to self-signed sertificates.

### Minikube

For start local cluster and synchronise, just run

```bash
make local
```

It will run next commands, but you can run them by self:

```bash
# Start minikube server
minikube start

# Enable minikkube ingress before sync
make minikube-ingress # or minikube addons enable ingress

# for synchromise cluster
make sync # or helmfile sync
```

---

Get external ip, for access your cluster outside

```bash
make minikube-ip
```

And add to `/etc/hosts` file next line

```hosts
# For access local cubernetes cluster
<your-external-ip> dashboard.k8s.local prometheus.k8s.local thanos-gateway.k8s.local grafana.k8s.local alertmanager.k8s.local k8s.local
```

## Kubernetes Dashboard

For access kubernets dashboard you need firstly get token:

```bash
# list existing secrets
kubectl -n kubernetes-dashboard get secrets
# pass correct name of secret
kubectl -n kubernetes-dashboard describe secret kubernetes-dashboard-token-<some-id>
# copy token
```

Then you can open page and pass token

### Though Ingress

open <https://dashboard.k8s.local> and pass copied token

### Through proxy

create local proxy

```bash
kubectl proxy
```

open <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:https/proxy/>
and pass copied token

## Grafana for Promtheus cluster metrics

You can open Grafana at `grafana.k8s.local`
for login as admiin use username `admin` and password `prom-operator`

Change password in `helfile.yaml` in `kube-prometheus-stack` grafana section.