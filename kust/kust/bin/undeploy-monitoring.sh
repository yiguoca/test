#!/bin/bash -x
DC=$1
EXTRAS=$2
./build-prometheus.sh "${DC}"

if [[ "${EXTRAS}" != "" ]]
then
  ./build-with-plugins.sh "cluster/${DC}/monitoring-extras" | kubectl delete -f - 2>&1 | sed /unchanged/d
fi

kubectl delete -lskip!=these -f "./manifests/prometheus/${DC}.yaml"
kubectl delete -ldelete=these -f "./manifests/prometheus/${DC}.yaml"
kubectl delete -lstage=one -f "./manifests/prometheus/${DC}.yaml"
kubectl delete -ldelete=these -f "./manifests/prometheus/${DC}.yaml"
