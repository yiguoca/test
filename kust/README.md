# Infrastructure managed by Kustomize

Kustomize project for infrastructure components managed separately from application Kustomization.

# Purpose

Separate infrastructure concerns from application.  Contains necessary Kustomization to deploy all our infrastructure components into all of our Kubernetes clusters.

## Installation Stages
Most infrastructure components require two stages to set up properly.  The typical first stage is to deploy Kubernetes Custom Resource Definitions (CRD) and start an Operator.  The second stage is to deploy our instances of the CRD and let the Operator take the necessary actions to sync state.

For example, with Elastic you cannot define an "Elasticsearch" Custom Resource (CR) until the CRDs have been registered with the Kubernetes API.  If you are applying YAML with both the CRD and CR to the cluster at the same time, typically the CRD won't be registered fast enough for the Kubernetes API to accept your CR.

## Layout

### Bases folder
Basic configuration YAML for each component is under "bases".  This will typically include CRD, RBAC, DaemonSets and so on.  For example, the base configuration for Elastic is under "bases/elastic" and it defines several resources including a Deployment for the elastic-system application.

YAML under bases is typically going to be a clone of some 3rd party install.  If we need to Kustomize it, then we should be making it clear which files are externally sourced and which ones are ours.  We could reference external resources by a git reference, but if we want guaranteed reproducibility then we need to clone.

Nothing cluster specific should be specified in a "base".

### Cluster folder

Structure under Cluster is:
- cluster name
  - component
    - stage1
    - stage2
    ...

As an example:  cluster/test/elastic/stage1  would render YAML that installs the Elastic CRDs and Operator for the "test" cluster.

Stage 2 would create the CR and any other supporting resources that depend on Stage 1 being applied to the cluster.

## Day 2 Operations
The first stage of installation rarely needs to be repeated.  Typically, this will happen when we are doing an upgrade of the component itself.

The second stage may be applied independently of the first stage at "Day 2" since this will typically cause the Operator to take a controlled action.  For example, if you were to update an "Elasticsearch" CR to define a new data node, the Elastic Operator will not destroy the world and rebuild your Elastic cluster from scratch, it'll just add the new node and reconfigure itself without disruption.

## Base Components
See the individual READMEs for operational details.

### [Elastic Cloud for Kubernetes](./bases/elastic-system/README.md)
Reapply is safe.  Delete will lose all data - elastic indexes, ad hoc Kibana dashboards, users, etc.

### [Event Job Runner](./bases/event-job-runner/README.md)
All operations are safe.

### [Gitlab Runner](./bases/gitabrunner/README.md)

### [HPE-CSI](./bases/hpe-csi/README.md)
Reapply is safe.  Delete will break everything using a Persistent Volume backed by the HPE Storage Class(es) and lose all your data.

### [Metacontroller](./bases/metacontroller/README.md)
All operations are safe.

### [Logstash](./bases/logstash/README.md) *WIP*
One stage only - safe to reapply and delete.  Consumer state is stored in Kafka.

### [Metacontroller](./bases/metacontroller/README.md)
One stage for CRDs, another for the deployment.  Safe to redeploy/delete.  EventJobRunner depends on this.

### Prom2Teams
Safe to delete/redeploy.   Expects Prometheus (monitoring namespace) to be deployed first.

### [Prometheus Operator](https://github.com/prometheus-operator)
Found under `prometheus` creates monitoring namespace and deploys operator and HA prometheus cluster pair. No PV for prometheus yet. Up to 2hrs of metrics will be lost if the Prometheus Stateful Set is forced off a node (e.g. during KubeAPI upgrade), or deleted and recreated.

### [PushGateway](https://github.com/prometheus/pushgateway)
Safe to delete/redeploy.  Expects monitoring namespace to exist, but does not require anything else to run properly.

### [Rancher](./bases/rancher/README.md)
Reapply is safe. Configures base setup post rancher installation.

### [Where Am I](./bases/whereami/README.md)
One stage only.  Safe to reapply and delete - stateless.

## Kustomize Targets
Kustomize 3.5.3+ is required.   Do not use the kustomize functionality included in kubectl.

You can render manifests with `kustomize build <folder>` where folder is any of the following sets:
- Install (stage 1) with customization for a specific cluster target:
cluster/test/elastic/stage1
cluster/ctkube/elastic/stage1
...
cluster/test/rook-ceph/stage1
... and so on.
- Create CRs and additional supporting Kubernetes Resources for a component:
cluster/test/elastic/stage2
cluster/ctkube/elastic/stage2
...
cluster/test/rook-ceph/stage2
... and so on.

## Helm template using kustomize
This requires kustomize version 4.1.0+, and expects helm 3 to be installed.

