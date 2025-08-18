# [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)

Orchestrates the deployment of a Prometheus cluster.

- Highly Available pair of Prometheus instances
- Node Exporter (Metrics)
- Grafana

We also add a couple extras:

- Mysqld exporter (DB monitoring)
- "whereami" service

## Grafana Dashboards

Some dashboards are cluster specific and must be added under the `/cluster/<name>/prometheus` folder.

Common dashboards can be defined here with the base.

## Upstream Changes

This Kustomization references the [Kube Prometheus](https://github.com/prometheus-operator/kube-prometheus) project as a resource. Kube-prometheus provides a complete cluster monitoring stack versus quickstart support and minimal custom resource setup of prometheus-operator project.

The project claims that latest is always stable, but seems to be targetting the latest Kubernetes API Version which is something that isn't going to work well for us.

See [Compatibility Chart](https://github.com/prometheus-operator/kube-prometheus/#compatibility) for details.

As a result, this project is locked at `release-0.9` to match Kubernetes 1.21 (Our current Kube version at present).

## Notes

kube-state-metrics, kube-rbac-proxy-main, kube-rbac-proxy-self, prometheus-adapter, kube-rbac-proxy all get defined without resource limits. We may want to patch those while generating the kustomization.
