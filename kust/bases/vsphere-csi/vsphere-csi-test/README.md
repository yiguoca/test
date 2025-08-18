This manages a collection of test operations that can be utilized to verify the setup/configuration of the vsphere-csi-driver and its respective storage resources.

To accomplish this we wrap the following test cases into a statefulset:

1. Can we successfully mount the pvc
1. Can we successfully read and write to the pvc

----

## How to Use

The `StatefulSet`'s VolumeClaimTemplate does not supply the storageClassName; this is to force the user to supply the correct one. For example:

```yaml
patches:
  - target:
      kind: StatefulSet
      name: test-node
    patch: |
      - op: replace
        path: "/spec/volumeClaimTemplates/0/spec/storageClassName"
        value: "vsphere-london-non-prod-delete"
```

In this example we set the value to `vsphere-london-non-prod-delete`.

## FAQ

#### StatefulSet vs DaemonSet

We chose a statefulset because we need to dynamically generate pvcs (vsphere-csi does not permited `ReadWriteMany`) and we dont want to manually create all the pvcs per node for the daemonset. So a statefulset works; though we will want to as part of the pipeline dymically alter the `replicas` to match the number of worker nodes.

#### Getting StatefulSet to schedule on all required node(s)

You have two (2) options here:

1. Overlay/patch the kustomization so that you supply it with the number of replicas to be the same number of nodes you want to evalute on
1. Use a script that will patch the statefulset after deployment

Below is the script I used as I opted for \#2; since I can calculate at deployment how many nodes have the label as that helps indicate how many nodes we want to schedule on:

```
REPLICAS=$(kubectl get nodes -l storage/vsphere=true -o jsonpath='{.items[*].metadata.name}' | wc -w)
echo "[INFO] setting the number of replicas to $REPLICAS"
kubectl patch statefulset test-node -n vsphere-csi-test --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value": '$REPLICAS'}]'
```

#### Will it run on masters?

Yes, we have added `tolerations` to make it possible as long as the label `storage/vsphere=true` is present.