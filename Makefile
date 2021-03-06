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
	make create-dashboard-role
	make apps

sync: 
	helmfile apply
	make create-dashboard-role
	make apps

create-dashboard-role:
	kubectl delete --ignore-not-found=true clusterrolebinding kubernetes-dashboard
	kubectl create clusterrolebinding kubernetes-dashboard \
		--clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:kubernetes-dashboard

apps:
	kubectl apply -n argocd -f ./applications/

# ---------------------------------------------------------------------------------------------------------------------
# MINIKUBE
# ---------------------------------------------------------------------------------------------------------------------

# Setup local cluster
local: minikube setup

minikube:
	minikube start --addons=ingress
	make minikube-ingress

# Allow access without proxy
minikube-ingress:
	minikube addons enable ingress

# get the external IP of cluster
minikube-ip:
	minikube ip

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

proxy:
	kubectl proxy

contexts:
	kubectl config get-contexts

current-context:
	kubectl config current-context

secrets:
	kubectl get secrets