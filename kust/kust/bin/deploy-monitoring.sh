#!/bin/bash -x
DC=$1
EXTRAS=$2
./build-prometheus.sh "${DC}"
kubectl delete -ldelete=these -f "./manifests/prometheus/${DC}.yaml" --ignore-not-found
if kubectl api-resources | grep Prometheus; then
  kubectl replace -lstage=one -f "./manifests/prometheus/${DC}.yaml" # Replace instead of Delete/Create to avoid clobbering other namespaces using these CRDs
else
  kubectl create -lstage=one -f "./manifests/prometheus/${DC}.yaml" # Use Create if the CRD doesn't already exist
fi
kubectl wait --for condition=established --timeout=3m crd -lstage=one
kubectl create -lcreate=these -f "./manifests/prometheus/${DC}.yaml"
kubectl apply -lskip!=these -f "./manifests/prometheus/${DC}.yaml"
if [[ "${EXTRAS}" != "" ]]
then
  ./build-with-plugins.sh "cluster/${DC}/monitoring-extras" | kubectl apply -f - 2>&1 | sed /unchanged/d
fi

