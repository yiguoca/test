# [NFS CSI Driver](https://github.com/kubernetes-csi/csi-driver-nfs)


#### Contents:

[[_TOC_]]

---
### NFS CSI Driver - What is it?

The NFS CSI driver from the Kubernetes CSI maintainers is used to wrap `RWO` volumes from another storageclass and expose the volumes as `RWX` volumes for other pods in the same namespace to consume.

### Dependencies

The pvc's this base spec provisions require the nfs-csi-driver base to be deployed in the kubernetes cluster you're deploying to. See `../csi-driver-nfs/` for details.

### What's in the base...

**stage1-pvc** - deploy NFS server `StatefulSet` and `Service`, RWX `PersistentVolume`, and RWX `PersistentVolumeClaim` 

**Do not deploy as-is.** Use them as bases for creating your own NFS server deployments in other namespaces (see 'Using This Deployment' below)

**Example:** see cluster/test/csi-driver-nfs-pvc-test/stage1-pvc-test for how to create a statefulset that mounts the RWX volume to multiple pods, and the intended structure of a project consuming these RWX volumes  

## Using This Deployment

### Example Project Structure
In the example below the "rwx-statefulset.yaml" is a test application that defines a `Service` and a `StatefulSet` and verifies the `StatefulSet`'s RWX pvc is mountable, writeable, and persists data. 
```
kustom-infrastructure/test/csi-driver-nfs-pvc-test
├── stage1-namespace
│   ├── kustomization.yaml
│   └── namespace.yaml
│
├── stage2-nfs-server
│   └── kustomization.yaml                -> deploys NFS server (see 'Example Overlay' below)
│
├── stage3-rwx-pvc
│   └── kustomization.yaml                -> deploys RWX pv & pvc (see 'Example Overlay' below)
│
└── stage4-testapp
    ├── kustomization.yaml                
    └── rwx-statefulset.yaml              -> deploys sample application, mounts the RWX pvc to it's pods
```
**Note:** This means we can only deploy a single RWX pvc per namespace. (POC for multiple RWX vols in same NS is WIP)

### Example Overlay
To deploy you're own NFS server and RWX access mode pvc, you'll need a namespace and a kustomization.yaml with (at minimum) the configs below. Run "find and replace" against the placeholders below and add the patches in this spec to your deployment. Only replace the placeholder phrases where they appear capitalized.

 - `NAMESPACE`: replace with the namespace you're deploying to
 - `PVC`: replace with a name for your pvc, unique to your namespace
 - `CLUSTER_DOMAIN`: replace with the cluster domain for the cluster you plan on deploying to
 - `PATH`: replace with the path from the file's dir to the "bases" dir in the root of the kustom-infrastructure project (usually a series of appended `../`)
 - `STORAGE_CAP`: size of the RWX volume you need (ie. 4Ki, 12Mi, 1Gi...)
 - `STORAGE_CLASS`: the storage class from the cluster you're deploying to
 - `RECLAIM_POLICY`: the reclaim policy for the RWX pv backed by the NFS server (ie. Retain or Delete)

**Template** - stage2-nfs-server/kustomization.yaml:
```
namespace: NAMESPACE

resources:
  - PATH/bases/csi-driver-nfs-pvc/stage1-nfs-server

patches:
  - target:
      kind: Service
      name: nfs-server-pvcname
    patch: |-
      - op: replace
        path: "/metadata/labels/app"
        value: nfs-server-PVC
      - op: replace
        path: "/spec/selector/app"
        value: nfs-server-PVC
      - op: replace
        path: "/metadata/name"
        value: nfs-server-PVC
  - target:
      kind: StatefulSet
      name: nfs-server-pvcname
    patch: |-
      - op: replace
        path: "/metadata/labels/app"
        value: nfs-server-PVC
      - op: replace
        path: "/metadata/labels/app.kubernetes.io~1name"
        value: nfs-server-PVC
      - op: replace
        path: "/spec/selector/matchLabels/app"
        value: nfs-server-PVC
      - op: replace
        path: "/spec/volumeClaimTemplates/0/spec/storageClassName"
        value: STORAGE_CLASS
      - op: replace
        path: "/spec/volumeClaimTemplates/0/spec/resources/requests/storage"
        value: STORAGE_CAP
      - op: replace
        path: "/spec/serviceName"
        value: nfs-server-PVC
      - op: replace
        path: "/spec/template/metadata/labels/app"
        value: nfs-server-PVC
      - op: replace
        path: "/spec/template/metadata/labels/app.kubernetes.io~1name"
        value: nfs-server-PVC
      - op: replace
        path: "/metadata/name"
        value: nfs-server-PVC
```

**Template** - stage3-rwx-pvc/kustomization.yaml:
```
namespace: NAMESPACE

resources:
  - PATH/bases/csi-driver-nfs-pvc/stage2-pvc

patches:
  - target:
      kind: PersistentVolume
      name: nfs-rwx-pvcname
    patch: |-
      - op: replace
        path: "/spec/csi/volumeHandle"
        value: nfs-server-PVC.NAMESPACE.svc.CLUSTER_DOMAIN##share
      - op: replace
        path: "/spec/csi/volumeAttributes/server"
        value: nfs-server-PVC.NAMESPACE.svc.CLUSTER_DOMAIN
      - op: replace
        path: "/spec/capacity/storage"
        value: STORAGE_CAP
      - op: replace
        path: "/spec/persistentVolumeReclaimPolicy"
        value: RECLAIM_POLICY
      - op: replace
        path: "/metadata/name"
        value: nfs-rwx-NAMESPACE-PVC
  - target:
      kind: PersistentVolumeClaim
      name: nfs-rwx-pvcname
    patch: |-
      - op: replace
        path: "/spec/volumeName"
        value: nfs-rwx-NAMESPACE-PVC
      - op: replace
        path: "/spec/resources/requests/storage"
        value: STORAGE_CAP
      - op: replace
        path: "/metadata/name"
        value: nfs-rwx-PVC
```

### Deleting NFS Server PVCs
When deleting these namespaces, you need to delete resources in 2 phases:
1. delete the application using the RWX pvc
1. delete the RWX pvc and pv to completion
1. delete the NFS server and all other resources

To make this easier, I split each RWX PVC kustomize spec into multiple directories:
1. one for the namespace the environment is deploying to
1. one for the NFS server statefulset, service, and RWO pvc resources
1. one for the RWX pv, and RWX pvc
1. one for the testapp running atop a mounted RWX volume

Examples of CICD job specs for deleting NFS servers in the right order can be found in `.gitlab-ci.storage.nfs.yaml` at the root of this Gitlab repo. Search for the "undeploy" keyword.

## Known Issues

#### RWX PV Stuck in Terminating
If you delete all the resources at once, the NFS server is usually deleted before the RWX PersistentVolume can fully delete itself from the NFS server. This traps the RWX PersistentVolume in a `Terminating` state, unable to reach it's backing NFS server to delete the NFS share that backs the PV.

**Note:** The RWX PersistentVolume will also be stuck in a terminating state if the NFS server is still deployed, but the FQDN for the NFS server in the RWX PersistentVolume spec doesn't match the `Service` for the NFS server you provisioned.

#### Workaround
1. Force delete the pv. Replace `PV_NAME` in the command below with the name of your PersistenVolume.
```
kubectl delete pv <PV_NAME> --force --grace-period=0
```
2. Remove the finalizers from the pv. Replace `PV_NAME` in the command below with the name of your PersistenVolume.
```
kubectl patch pv <PV_NAME> -p '{"metadata": {"finalizers": null}}'
```
---
next known issue...  
