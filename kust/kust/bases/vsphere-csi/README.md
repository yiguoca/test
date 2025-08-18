Contains the kustomization definitions for the distribution of [VSphere Container Storage Interface (CSI)] within our kubernetes clusters. Because we need to deploy in "stages" where one component requires the existance of another we have logically broken up the kustomization to facilitate this.

1. [vsphere-csi-drive](./vsphere-csi-driver/) - the container storage interface for interacting with vsphere/vmware storage
1. [vsphere-csi-test] - a test suite that contains a collection of resources that can be deployed to verify and confirm the cluster is in the expected state for handling storage backed by vsphere.

For indepth discussion, refer to each component's `README.md`.

[VSphere Container Storage Interface (CSI)]: https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container-storage-plugin/3-0/

----

# Node Labeling

The idea here is to provide the ability to use the vsphere-csi as the storage backend as long as the node has the label `storage/vsphere=true` present on it. This is because many of the deamonsets and deployments defined by the vendor provide taints. Generally we dont want to run anything on masters where possible, the need to have the `vsphere-csi-node` pods running on the master taking up resources can be avoided by this simple label fix.

# What do I do add more node(s) to my cluster to utilize vsphere?

You just need to update each node to have the label `storage/vsphere=true`; this will allow the `vsphere-csi-node` to immediatally spin up on the new node(s). 

We do recommend using the pipeline to do the labeling and redeployment that way if you have enabled the csi tests we have created we can verify the node can attach to the pvc.