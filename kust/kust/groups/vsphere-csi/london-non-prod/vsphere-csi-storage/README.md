Defines and manages all the storage classes (storageclass, snapshotgroupclass, volumesnapshotclass etc) that utilize the [vsphere-csi](../vsphere-csi/) as it backing storage implementation.

----

## StorageClasses

A series of storage classes that use the `storagepolicyname`: **`Stellantis_Pri_NonProd_Kube_Storage`**

The storage classes defined are:

- `vsphere-london-non-prod-delete`
- `vsphere-london-non-prod-retain`

> Post migration away from nimble, we should modify `vsphere-london-non-prod-delete` so that it is the default storage class.

## VolumeSnapshotClasses

- `vsphere-london-non-prod-volume-snapshot-delete`
- `vsphere-london-non-prod-volume-snapshot-retain`

## How to Use

Because in the case of non prod not all our clusters require persistent storage but only require ephemeral we have divided this logic up into two (2) sub folders:

- `ephemeral/` - contains all classes with `-delete`; which means there `reclaimPolicy` generally means `Delete`
- `persistent/` - contains all classes with `-retain`; which means there `reclaimPolicy` generally means `Retain`

## FAQ

#### How do we validate/test at high level the vsphere-csi?

When testing out these classes, refer to [vshpere-csi-test](../vsphere-csi-test/) folder.

#### Why not bundle with [./vsphere-csi-driver](../vsphere-csi-driver/)?

We want to keep the csi seperate because there are different stages to setting up the vsphere storage, but also so that we know the csi folder only defines stuff for the csi; and this folder only defines thins for using the vsphere-csi.