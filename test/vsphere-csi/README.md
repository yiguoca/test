Contains the kustomization definitions for the distribution of [VSphere Container Storage Interface (CSI)] within the `fcaus-te` kubernetes cluster. Because we need to deploy in "stages" where one component requires the existance of another we have logically broken up the kustomization to facilitate this.

1. [vsphere-cpi](./vsphere-cpi/) - a prereq for the [vsphere-csi-drive]
1. [vsphere-csi-drive](./vsphere-csi-driver/) - the container storage interface for interacting with vsphere/vmware storage
1. [vsphere-csi-storage](./vsphere-csi-storage/) - provides the various classes required for generating persistent volumes with the csi driver (such as `StorageClass`)
1. [vsphere-csi-test] - a test suite that contains a collection of resources that can be deployed to verify and confirm the cluster is in the expected state for handling storage backed by vsphere.

For indepth discussion, refer to each component's `README.md`.

[VSphere Container Storage Interface (CSI)]: https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container-storage-plugin/3-0/