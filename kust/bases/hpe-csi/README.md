# [HPE CSI Driver](https://github.com/hpe-storage/csi-driver) for Kubernetes

Hewlett Packard Enterprise (HPE)  
Container Storage Interface (CSI)

Storage Provisioner for Kubernetes that allocates storage from a HPE Nimble storage array.

This allows us to connect a Kubernetes cluster to SAN (storage area network) backed storage.

In theory we will be able to leverage the reliability and redundancy of the existing SAN infrastructure in Kubernetes.

First timers getting familiar with [storage in kubernetes](https://kubernetes.io/docs/concepts/storage/), start out by reviewing the documentation in our [system architecture](https://git.autodatacorp.org/fcaus/system-architecture-docs/persistent-storage/README.md) project.  
Head back here for specifics on the rollout in our environment. Details on initial ticket creation for environment setup is over in the [system architecture](https://git.autodatacorp.org/fcaus/system-architecture-docs/persistent-storage/hpe-csi.md#initial-setup-tickets) project as well.

## Dependencies

[csi-snapshotter](/bases/csi-snapshotter/README.md)

## Beware
Tearing down the HPE CSI driver and redeploying it will likely require you to import any `PersistentVolumes` (PVs) associated with existing `PersistentVolumeClaims` (PVCs). Volumes do remain on the Nimble Storage Array unless `destroyOnDelete: "true"` is set during provisioning and `PersistentVolumes` are deleted.

## Upgrading Helm Charts

To upgrade the charts being referenced, please do the following:
- remove the [charts](charts) folder
- update the `helmCharts` versions you need in the [kustomization.yaml](kustomization.yaml)
- re-render the charts folder using `./build-with-plugins.sh bases/hpe-csi`
- git add and commit the [charts](charts) folder to pick up the changes

## Pre-requisites

Satisfy the [pre-requisites](https://git.autodatacorp.org/fcaus/system-architecture-docs/persistent-storage/hpe-csi.md#pre-requisites)

#### HPE Installs Ubuntu packages
When iscsi is not installed on the host machine HPE will install it for you.  If your VM is locked down you may need the Linux team to install it as a pre-step.

## [Storage Retention Use Cases](https://git.autodatacorp.org/fcaus/system-architecture-docs/persistent-storage/hpe-csi.md#storage-retention-use-cases)

## [Resiliency, Snapshot and Restore Scenarios](https://git.autodatacorp.org/fcaus/system-architecture-docs/persistent-storage/hpe-csi.md#resiliency-snapshot-and-restore-scenarios)

## Enabling debug loglevel

To enable debug in all cluster deployments simply update the inline values of the [base kustomization](./kustomization.yaml) and add the appropriate debug values `logLevel`. Otherwise for specific hpe-csi-driver components or in specific cluster apply a patch. For a cluster specific example see [loglevel-debug patches](../../cluster/test/hpe-csi/stage1/patches/loglevel-debug/) in the test cluster overlay.

## `nimble-secret`
A secret needs to be created to define the Nimble REST API end point (not the iSCSI discovery IP) location and credentials. See the Nimble secret generator [thycotic plugin](../../plugin/fca.autodata.net/v1.1/thycoticnimblesecretgenerator/ThycoticNimbleSecretGenerator) for fields required to setup an appropriate secret server record.

Example Secret 
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: nimble
  namespace: hpe-storage
stringData:
  serviceName: nimble-csp-service
  servicePort: "8080"
  backend: 172.16.128.130
  username: stellantis-us-k8s-storage
  password: password1234!
```

## `StorageClass`
Once the operator is installed you will need to define a `StorageClass` resource so that PV/PVCs can be created.

Based on different use cases for storage needs and which Nimble policies or features will be used it is likely a few different `StorageClasses` will be required. Keep in mind before creating a new `StorageClass` the `allowOverrides` parameter supports [pvc overrides](https://scod.hpedev.io/csi_driver/using.html#using_pvc_overrides) to certain [parameters](https://scod.hpedev.io/csi_driver/using.html#base_storageclass_parameters). Nimble backed CSI Driver also provides additional [provider specific parameters](https://scod.hpedev.io/container_storage_provider/hpe_alletra_6000/index.html#storageclass_parameters).

Example StorageClass
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: nimble-delete
provisioner: csi.hpe.com
parameters:
csi.storage.k8s.io/fstype: ext4
  csi.storage.k8s.io/controller-expand-secret-name: nimble
  csi.storage.k8s.io/controller-expand-secret-namespace: hpe-storage
  csi.storage.k8s.io/controller-publish-secret-name: nimble
  csi.storage.k8s.io/controller-publish-secret-namespace: hpe-storage
  csi.storage.k8s.io/node-publish-secret-name: nimble
  csi.storage.k8s.io/node-publish-secret-namespace: hpe-storage
  csi.storage.k8s.io/node-stage-secret-name: nimble
  csi.storage.k8s.io/node-stage-secret-namespace: hpe-storage
  csi.storage.k8s.io/provisioner-secret-name: nimble
  csi.storage.k8s.io/provisioner-secret-namespace: hpe-storage
  description: "Volume provisioned by the HPE CSI Driver"
  destroyOnDelete: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

### Notable Parameters

*destroyOnDelete* - Depending on the lifecycle of your application and retention requirements of persistent storage (i.e. disk cache vs archival reporting) the parameter will ensure the driver cleans up provisioned volumes on the storage array while cleaning up the Kubernetes resources. Without it a `Storage Administrator` will be required to manually prune any volumes created. *IMPORTANT NOTE*: Any volume initiatlly created with `destroyOnDelete: "false"` or default (false) will need to be manually deleted by a Storage Administrator even after reimporting the volume with a `PersistentVolumeClaim` override of `destroyOnDelete: "true"`. A volume initially created by a `PersistentVolumeClaim` with annotated override for `destroyOnDelete: "true"` when the `StorageClass` referenced is set with `destroyOnDelete: "false"` or default will be honoured.

*performancePolicy* - While any custom policy can be defined the defaults listed for Nimble are in use and exist in our Storage Arrays.

*protectionTemplate* - While any custom template can be defined the defaults listed for Nimble are in use and exist in our Storage Arrays.

*folder* - Please organize your volumes!!!

Check out the Nimble provider specific [Provisioning](https://scod.hpedev.io/container_storage_provider/hpe_alletra_6000/index.html#provisioning_parameters), [Clonning](https://scod.hpedev.io/container_storage_provider/hpe_alletra_6000/index.html#cloning_parameters), and [Import](https://scod.hpedev.io/container_storage_provider/hpe_alletra_6000/index.html#import_parameters) for helpful information in different use cases.

## Issues

If you are troubleshooting and need help from one of our Windows/Storage Admins they will need to know the id of the PVC (i.e. its `/spec/volumeName`, e.g. `pvc-262677dd2602-4ddb-935c-07a4426b06ac`) to search for issues on the Nimble side.

### Access to Nimble REST API
The `nimble-secret` username and password will need "poweruser" level access to the Nimble REST API.  The "operator" level does not allow the HPE CSI software to delete a volume.

The HPE-CSI driver (operator) uses the [Nimble API](https://infosight.hpe.com/InfoSight/media/cms/active/public/pubs_REST_API_Reference_NOS_51x.whz/jun1455055569904.html) to provision volumes on the storage array and then populate a `PersistentVolume` resource with a variety of connection/volume details.

Example of a PV - do NOT create these yourself - HPE CSI is a dynamic provisioner and will create these when you create a PVC.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: csi.hpe.com
  creationTimestamp: "2020-03-03T22:27:23Z"
  finalizers:
  - kubernetes.io/pv-protection
  - external-attacher/csi-hpe-com
  name: pvc-7b00e3f2-b2ff-4b85-a33b-ba62486d3c7f      <- this is visible in the Nimble logs for Ops support.
  resourceVersion: "13554092"
  selfLink: /api/v1/persistentvolumes/pvc-7b00e3f2-b2ff-4b85-a33b-ba62486d3c7f
  uid: e06d29e2-8590-4d50-a9f4-b52bb3ef4bdf
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 50Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: elasticsearch-data-eck-es-eck-data-2
    namespace: eck
    resourceVersion: "13554017"
    uid: 7b00e3f2-b2ff-4b85-a33b-ba62486d3c7f
  csi:
    controllerPublishSecretRef:
      name: nimble-secret
      namespace: kube-system
    driver: csi.hpe.com
    fsType: ext4
    nodePublishSecretRef:
      name: nimble-secret
      namespace: kube-system
    nodeStageSecretRef:
      name: nimble-secret
      namespace: kube-system
    volumeAttributes:
      description: Volume provisioned by the HPE CSI Driver
      fsType: ext4
      storage.kubernetes.io/csiProvisionerIdentity: 1583270243550-8081-csi.hpe.com
      volumeAccessMode: mount
    volumeHandle: 0672183419a055319f000000000000000000000060
  persistentVolumeReclaimPolicy: Delete
  storageClassName: hpe-nimble
  volumeMode: Filesystem
status:
  phase: Bound
```

### Access to the Nimble Array
The iSCSI endpoints are not accessible on the internal network unless you are on a specific VLAN.  This is not normally a concern for our VMs as the Windows Admins are provisioning and mounting the storage into our VMs for us.  The ESX hosts that run the VMs have a dedicated network interface for accessing Nimble.

For Kubernetes worker nodes, we need to provision additional NICs and allocate `Discovery IPs` (varies depending on Data Center) so that we can mount the volumes. `Discovery IPs` can be found by requesting network configs from the tenant api `/api/tenant/v1/network_configs/detail?role=active` or [enabling debug]() on the csi driver and reviewing logs.

Example logged response from our test Nimble API.
```
03:01:54 DEBUG [co.ni.hi.cs.se.ResponseLoggingFilter]] (executor-thread-1) Entity: {
  "serial_number" : "ab8b68469dcb93196c9ce9007ef18017",
  "target_names" : [ "iqn.2007-11.com.nimblestorage:pvc-7ccb15d1-9a77-4825-9f03-71760cee4c9f-v526274f145e2858f.00000090.1780f17e" ],
  "access_protocol" : "iscsi",
  "lun_id" : 0,
  "discovery_ips" : [ "xx.xx.xx.xx", "xx.xx.xx.xx" ]
}
```

*Note:* NICs will not necessarily be detected automatically by the OS a system administrator is required to configure. 

### Access to Nimble Tenant

Administrative access to the Storage Array will not be permitted. Ultimately, there would be far too much risk for potential error and significant data loss by providing complete administrative access over the Storage Array. HPE CSI Driver requires a higher level of access to fully support dynamic provisioning and offer self-service capabilities. 

As discussed in the [references](#references), the Nimble `tenantadmin` cli enables creation of user accounts, confined to a tenant, with full privileges to manage any aspect of volumes within the folder. 

Storage Administrators will need to provide username, backend (IP to the tenant API server), password and optionally the folder(s) available, to configure your kubernetes secret. 
