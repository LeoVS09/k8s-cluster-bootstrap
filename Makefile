#!/usr/bin/env make

.PHONY: sync dashboard proxy contexts current-context dashboard-proxy minikube minikube-ingress minikube-ip

default: sync


# ---------------------------------------------------------------------------------------------------------------------
# SETUP
# ---------------------------------------------------------------------------------------------------------------------

sync:
	helmfile sync
	make create-dashboard-role

create-dashboard-role:
	kubectl delete clusterrolebinding kubernetes-dashboard
	kubectl create clusterrolebinding kubernetes-dashboard \
		--clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:kubernetes-dashboard

# ---------------------------------------------------------------------------------------------------------------------
# MINIKUBE
# ---------------------------------------------------------------------------------------------------------------------

minikube:
	minikube start
	make minikube-ingress

# Allow access without proxy
minikube-ingress:
	minikube addons enable ingress

# get the external IP of cluster
minikube-ip:
	minikube ip

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