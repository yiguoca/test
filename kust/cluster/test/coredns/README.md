# CoreDNS configuration

This may be better suited as a Rancher cluster configuration as RKE is provisioning CoreDNS during cluster creation.

For now, this kustomization target will render a ConfigMap that overrides the default cluster configuration in order to alias *.cluster.local.  This allows various operators that have `cluster.local` hardcoded to work.