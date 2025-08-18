# [NFS CSI Driver](https://github.com/kubernetes-csi/csi-driver-nfs)


#### Contents:

[[_TOC_]]

---
### NFS CSI Driver - What is it?

The NFS CSI driver from the Kubernetes CSI maintainers is used to wrap `RWO` volumes from another csi driver and expose the volumes as `RWX` volumes for other pods in the same namespace to consume. Note that this CSI driver is not setup to be consumed as a storageclass. See `../csi-driver-nfs-pvc` in this project for details

### What's in the base...

**stage1-driver** - deploy the nfs csi driver (CRD, csidriver)  

## Using This Deployment

In Gitlab, run the Build > Pipelines > (branch of your choice) and run the job named `TBD` for the environment you're depoying to. You can validate the csi driver is present after the deployment by running `kubectl get csidriver` against the cluster you deployed to.

## Deploying an RWX PersistentVolumeClaim

See the base for `csi-driver-nfs-pvc`, and consult it's README for details.

