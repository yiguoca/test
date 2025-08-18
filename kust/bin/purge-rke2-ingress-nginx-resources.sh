#!/bin/bash
# This script is used to purge the resources created by the rke2-ingress-nginx deployed with rancher upgrades.
# The resources to be deleted were identified by performing a diff between a basic rke2 ingress-nginx deployment and one
# that has our expected changes.  See cluster/test/kube-system/rke2-ingress-nginx kustomization for re-generating the diff.
kubectl -n kube-system delete serviceaccounts rke2-ingress-nginx-admission --ignore-not-found
kubectl -n kube-system delete role rke2-ingress-nginx-admission --ignore-not-found
kubectl -n kube-system delete rolebindings.rbac.authorization.k8s.io rke2-ingress-ngin-admission --ignore-not-found
kubectl -n kube-system delete clusterrolebindings.rbac.authorization.k8s.io rke2-ingress-nginx-admission --ignore-not-found
kubectl -n kube-system delete service rke2-ingress-nginx-controller-admission --ignore-not-found
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io rke2-ingress-nginx-admission --ignore-not-found
kubectl delete clusterrole rke2-ingress-nginx-admission --ignore-not-found
