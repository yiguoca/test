#!/usr/bin/env bash

# TODO - update script to handle "component" and "stage" to allow for a generic
# infrastructure build script.

set -e
set -o pipefail

if [ $# -eq 0 ]
then
  echo "Please provide cluster name (e.g. chaska, hillsboro, test, etc.)"
  exit 1
fi

# make sure the kustomization exists before we make a mess
if [ ! -f "./cluster/$1/prometheus/kustomization.yaml" ]
then
  echo "Expected to find ./cluster/$1/prometheus/kustomization.yaml"
  exit 1
fi

mkdir -p "manifests/prometheus"

if ./build-with-plugins.sh "./cluster/$1/prometheus" > "manifests/prometheus/$1.yaml"; then
  sed -i -e "s/prometheus-k8s/prometheus-$1/" -e "s/prometheus: k8s/prometheus: $1/" -e "s/name: k8s$/name: $1/" -e "s/instance: k8s$/instance: $1/" "manifests/prometheus/$1.yaml"
  echo "Successfully built ./cluster/$1/prometheus/kustomization.yaml"
  echo "Apply with the following or you'll deploy unwanted resources:"
  echo "kubectl delete -ldelete=these -f ./manifests/prometheus/$1.yaml"
  echo "kubectl delete -lstage=one -f ./manifests/prometheus/$1.yaml"
  echo "kubectl create -lstage=one -f ./manifests/prometheus/$1.yaml"
  echo "kubectl wait --for condition=established --timeout=3m crd -lstage=one"
  echo "kubectl create -lcreate=these -f ./manifests/prometheus/$1.yaml"
  echo "kubectl apply -lskip!=these -f ./manifests/prometheus/$1.yaml"
fi
