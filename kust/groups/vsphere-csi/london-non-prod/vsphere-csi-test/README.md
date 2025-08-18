This manages a collection of test operations that can be utilized to verify the setup/configuration of the vsphere-csi-driver and its respective storage resources. We extend the [base definition](/bases/vsphere-csi/vsphere-csi-test/) to execute all the common tests.

----

# Patches

We override the StatefulSet `test-node` to use the storageClassName `vsphere-london-non-prod-delete`