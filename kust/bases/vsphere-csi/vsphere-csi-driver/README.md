This manages the distribution of the [VSphere Container Storage Interface (CSI)] driver(s). 

To do this we utilize the kustomization provided by [github](https://github.com/kubernetes-sigs/vsphere-csi-driver/):

```
https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/v{{version}}/manifests/vanilla/vsphere-csi-driver.yaml
```

We need to use the version of the driver that complies with our kubernetes. This can be done by refering to the [compliance chart] provided by vmware's documentation.

In order to determine which versions available, refer to https://github.com/kubernetes-sigs/vsphere-csi-driver/releases

[VSphere Container Storage Interface (CSI)]: https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container-storage-plugin/3-0/getting-started-with-vmware-vsphere-container-storage-plug-in-3-0.html
[compliance chart]: https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container-storage-plugin/3-0/getting-started-with-vmware-vsphere-container-storage-plug-in-3-0/vsphere-container-storage-plug-in-concepts/compatibility-matrix-for-vsphere-container-storage-plug-in.html#GUID-D4AAD99E-9128-40CE-B89C-AD451DA8379D-en

----

## Requirements

This driver will require:

- the nodes to host have the label `storage/vsphere=true`

## Patches

We patch the `DaemonSet` so that it will only run on nodes that have been labeled with `storage/vsphere` with a value of `true`. This is to allow if we ever introduce different kind of csi's into the system but rely on different node architecture we can better allocate where the csi can be accepted on.

## Namespace

The vsphere-csi-driver allows you to deploy to any namespace, for cleanability we do this we deploy to the namespace `vmware-system-csi` which this folder also manages.

## How to Use