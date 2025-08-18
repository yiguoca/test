# NFS Provisioner

## Configuration
A patch must be applied to update the `NFS_SERVER` and `NFS_PATH` in the nfs-subdir-external-provisioner `Deployment` env and volumes sections.

```
patches:
  - target:
      kind: Deployment
      name: nfs-provisioner-nfs-subdir-external-provisioner
    patch: |-
      - op: replace
        path: "/spec/template/spec/volumes/0/nfs/path"
        value: "/your-exported/path"
      - op: replace
        path: "/spec/template/spec/volumes/0/nfs/server"
        value: your-nfs-server-name
      - op: replace
        path: "/spec/template/spec/containers/0/env/2/value"
        value: "/your-exported/path"
      - op: replace
        path: "/spec/template/spec/containers/0/env/1/value"
        value: your-nfs-server-name
```

## Upgrade helm charts

To upgrade the charts being referenced, please do the following: 
 - remove the [charts](charts)` folder
 - update the `helmCharts` versions you need updated in the [kustomization.yaml](kustomization.yaml)
 - re-render the charts folder using `./build-with-plugins.sh bases/nfs-provisioner`
 - git add and commit the [charts](charts) folder to pick up the changes
