# NFS CSI Driver

This spec deploys an RWX PVC and attaches it to a statefulset that proves the volume can be mounted, written to, and persists that data. It imports `bases/csi-driver-nfs-pvc` and overides all the placeholder values in the overlay.

For details on configuring RWX volumes, see `bases/csi-driver-nfs-pvc`.
