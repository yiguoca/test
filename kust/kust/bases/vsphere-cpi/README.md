This manages the distribution of the [vSphere Cloud Provider Interface (CPI)] driver(s) on the `kube-system` namespace.

In order to perform this operation we utilize the vsphere-csi kustomization and utilize patches and generators to supply the resources with our configurations/credentials.

```
  - https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/release-{{verersion}}/releases/v${{version}}/vsphere-cloud-controller-manager.yaml
```

To determine which [release](https://github.com/kubernetes/cloud-provider-vsphere/tree/master/releases) version we should associate with, refer to the [compatibility chart] provided by the documentation.

[vSphere Cloud Provider Interface (CPI)]: https://kubernetes.github.io/cloud-provider-vsphere
[compatibility chart]: https://kubernetes.github.io/cloud-provider-vsphere/#compatibility-with-kubernetes

----

## Patches

Remove the reference to `node-role.kubernetes.io/master` in the node selector of the `DaemonSet` as that looks to be added purely for backwards compatibility maybe and we dont need it (it causes a warning in the logs)