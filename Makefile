#!/usr/bin/env make

.PHONY: setup sync apps proxy contexts current-context dashboard-proxy local minikube minikube-ingress minikube-ip certificate-issuers

default: sync

# Apply .env if it exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# ---------------------------------------------------------------------------------------------------------------------
# SETUP
# ---------------------------------------------------------------------------------------------------------------------

# run on first setup
setup:
	helmfile sync
	make apply-base

sync: 
	helmfile apply
	make apply-base

apply-base:
	make create-dashboard-role
	make save-stackgres-profiles
	make save-wasabi-creds

# if kubernetes dashboard cannot list something
update-admin-role:
	kubectl apply -f ./rbac/cluster-admin.yaml

create-dashboard-role:
	kubectl delete --ignore-not-found=true clusterrolebinding kubernetes-dashboard
	kubectl create clusterrolebinding kubernetes-dashboard \
		--clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:kubernetes-dashboard

apps:
	kubectl apply -n argocd -f ./applications/

save-stackgres-profiles:
	kubectl apply -f ./manifests/stackgres-instance-profiles.yaml

# ---------------------------------------------------------------------------------------------------------------------
# MINIKUBE
# ---------------------------------------------------------------------------------------------------------------------

# Setup local cluster
local: minikube setup

minikube:
	minikube start --addons=ingress --memory='max' --cpus='max'
	make minikube-ingress

# Allow access without proxy
minikube-ingress:
	minikube addons enable ingress

# get the external IP of cluster
minikube-ip:
	minikube ip

# ---------------------------------------------------------------------------------------------------------------------
# REGISTRY
# ---------------------------------------------------------------------------------------------------------------------

save-wasabi-creds:
	kubectl delete --ignore-not-found=true secret wasabi-creds
	kubectl create secret generic wasabi-creds \
		--from-literal='AWS_ACCESS_KEY_ID=${WASABI_ACCESS_KEY_ID}' \
		--from-literal='AWS_SECRET_ACCESS_KEY=${WASABI_SECRET_ACCESS_KEY}' \
		--from-literal='AWS_REGION=${WASABI_REGION}' \
		--from-literal='AWS_DEFAULT_REGION=${WASABI_DEFAULT_REGION}'


save-docker-hub-creds:
	kubectl delete --ignore-not-found=true secret docker-hub-creds
	kubectl create secret generic docker-hub-creds \
		--from-file=.dockerconfigjson=./.docker/config.json \
		--type=kubernetes.io/dockerconfigjson

# ---------------------------------------------------------------------------------------------------------------------
# CERTIFICATE MANAGER
# ---------------------------------------------------------------------------------------------------------------------

certificate-issuers: certificate-issuer-staging certificate-issuer-prod

certificate-issuer-staging:
	envsubst < ./certificate/staging-issuer.yaml | kubectl apply -f -

certificate-issuer-prod:
	envsubst < ./certificate/production-issuer.yaml | kubectl apply -f -

# ---------------------------------------------------------------------------------------------------------------------
# USAGE
# ---------------------------------------------------------------------------------------------------------------------

contexts:
	kubectl config get-contexts

current-context:
	kubectl config current-context

secrets:
	kubectl get secrets

# ---------------------------------------------------------------------------------------------------------------------
# ACCESSS
# ---------------------------------------------------------------------------------------------------------------------

proxy:
	kubectl proxy

proxy-dashboard:
	kubectl port-forward -n kubernetes-dashboard kubernetes-dashboard-75bfbd4977-t58j8 8443:8443
	echo "Open at https://localhost:8443"
# If chrome not allow open localhost use chrome://flags/#allow-insecure-localhost

proxy-argo:
	echo "Open at https://localhost:8080"
	kubectl port-forw

proxy-grafana: 
	kubectl port-forward -n monitoring-logs-trace-stack  kube-prometheus-stack-grafana-7df49b8657-wfrdn 8081:3000