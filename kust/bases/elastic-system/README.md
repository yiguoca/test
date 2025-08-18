# Elastic Operator

Installs version 2.1.0 of the [Elastic Cloud on Kubernetes](https://www.elastic.co/guide/en/cloud-on-k8s/2.1/index.html) operator

*Note: stage4 is still a work in progress to populate cluster with predefined dashbaords, searches and indexes.*

## Kibana
When newly provisioned, there is only one user defined.  Username is `elastic` with a randomly generated password.

Find the password:
`kubectl -n <namespace> get secret <instancename>-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode`

## Persistent Volumes

The `ingest` and `master` nodes don't need much storage, however choosing too small of a PV also doesn't work as the OS can't format the volume.  Actual minimum isn't known and is likely different between StorageClasses defined with xfs vs ext4 filesystems.  From minimal experimentation, 10Mi is too small but 64Mi is fine for xfs.

Resizing of volumes has been added in recent versions of the operator.  Not tested by us yet.

## Cluster Bootstrapping
The operator does some magic to form the cluster on initial deploy.  The state and members of the cluster are stored with the master node(s).  If there is only one master node, and you *don't* use persistent storage, the cluster state will be lost when the master node restarts.  There is no way to recover this, you'll have to recreate the cluster.
TL;DR : use persistent storage for all node types.

## Monitoring
As of version 1.7 of the Operator, there is a way to monitor the cluster routing metrics to a central (in the same Kubernetes cluster) Elasticsearch cluster.

See [Monitoring](https://www.elastic.co/guide/en/cloud-on-k8s/1.8/k8s-stack-monitoring.html) for more information.

## Configuration
In more recent versions of ECK the operator will configure the JVM memory settings based on the Kubernetes resource definitions.

If you want specific traffic (cluster load) to go to specific node types you can take a look at [Traffic Splitting](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-traffic-splitting.html)

## Users
To create new users and roles available on cluster initialization see the documentation [k8s-users-and-roles](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-users-and-roles.html)
Plenty of documentation is available for the predefined roles and setting up custom roles using role management api or file-based management. 

Use the following kube definition to run elastic in a local kubernetes cluster and generate users.

* Create a temporary elastic-user-config directory to store generated users to store as secrets while creating elastic cluster.
* Create empty file for `users` and `users_roles` to be stored in the temporary directory.
* Execute the elasticsearch-users utility with useradd command user, password and roles. 
* `kubectl exec -it elastic-users -- /bin/bash`
* `/bin/elasticsearch-users useradd \[user\] -p \[password\] -r \[role\]`
* Locate the file in the mounted temporary directory.
* Use the files created to populate user secret on cluster initialization see `cluster/test/elastic/stage3/secrets/logging-elastic-users.yaml` or [elastic file realm documentaiton](https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-users-and-roles.html#k8s_file_realm).

TODO: Create thycotic elastic user secret generator, switch logging-elastic-users to thycotic secret.

[Kubernetes elasticsearch utilities deployment](https://git.autodatacorp.org/-/snippets/92)

## Upgrade Helm Chart
To upgrade the charts being referenced, please do the following:

remove the subfolder in the `charts` folders (see both stage1 and stage2)
update the helmCharts versions you need updated in the kustomization.yaml

re-render the charts folder using ./build-with-plugins.sh bases/elastic/

git add and commit the charts folder to pick up the changes

