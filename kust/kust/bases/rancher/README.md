# Rancher

Kustomization support for default rancher cluster setup. 


## RBAC

Role templates for use defining access across clusters.

Cluster Role Bindings are default access control for known groups requiring access to all clusters and their default access provided.

Any additional custom roles specific to a cluster will be specified in the respective cluster overlay.

Note: `cluster-owner` role referenced is a bootstrapped-role that exists in all clusters. Cluster Read Only is 