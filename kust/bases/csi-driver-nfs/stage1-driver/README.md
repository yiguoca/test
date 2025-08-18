# In-Cluster NFS Server - CSI Driver

## Configuration
TBD

## Upgrade helm charts

To upgrade the charts being referenced, please do the following: 
 - remove the [charts](charts)` folder
 - update the `helmCharts` versions you need updated in the [kustomization.yaml](kustomization.yaml)
 - re-render the charts folder using `./build-with-plugins.sh bases/csi-driver-nfs`
 - git add and commit the [charts](charts) folder to pick up the changes

