# [Turbonomic](https://github.com/turbonomic/) for Kubernetes [Kubeturbo](https://github.com/turbonomic/kubeturbo)

Compute monitoring across kubernetes platform. Kubeturbo offers observability and control over resources running in the kubernetes cluster to maximize utilization of underlying infrastructure. 

We deploy kubeturbo using a local helm chart approach with Kustomize. Considering IBM doesn't provide or at least reference where to locate a remote helm chart repository release of the kubeturbo charts, we pull the latest helm chart from their github repo and store in the `base/kube-turbo/charts` directory. See [upgrading helm charts](#upgrading-helm-charts) for the process to replace existing version with latest versions. 

## Dependencies

[csi-snapshotter](/bases/csi-snapshotter/README.md)

## Beware
Tearing down the HPE CSI driver and redeploying it will likely require you to import any `PersistentVolumes` (PVs) associated with existing `PersistentVolumeClaims` (PVCs). Volumes do remain on the Nimble Storage Array unless `destroyOnDelete: "true"` is set during provisioning and `PersistentVolumes` are deleted.

## Upgrading Helm Charts

To upgrade the charts being referenced, please do the following:
- remove the [kubeturbo](charts/kubeturbo/) folder
- navigate to [kubeturbo deploy](https://github.com/turbonomic/kubeturbo/tree/master/deploy/kubeturbo) directory and download the latest charts. 
- copy the latest charts into the [kubeturbo](charts/kubeturbo/) folder
- git add and commit the [charts](charts) folder to pick up the changes

## Pre-requisites

https://github.com/turbonomic/kubeturbo/wiki/Prerequisites
https://www.ibm.com/docs/en/tarm/8.14.2?topic=targets-kubeturbo-deployment-requirements

