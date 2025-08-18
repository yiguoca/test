Creates a secret to the configurable spec of [Create a Kubernetes Secret for vSphere Container Storage Plug-in](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container-storage-plugin/3-0/getting-started-with-vmware-vsphere-container-storage-plug-in-3-0/vsphere-container-storage-plug-in-deployment/deploying-vsphere-container-storage-plug-in-on-a-native-kubernetes-cluster/create-a-kubernetes-secret-for-vsphere-container-storage-plug-in.html) as defined in its documentation. This is done by using a simple thycotic Password type to do the following:

- to find the `host` if not supplied to your generate pull down from the passwords `resource` field
- build the user from passwords `username` field
- build the password fropm the passwords `password` field

Note that because operations will sometimes created accounts with a backslash (`\`) we need to espace it (`\\`).