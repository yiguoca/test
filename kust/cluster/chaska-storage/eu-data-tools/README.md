Defines the kustomizations for setting up supporting infrastructure for the
eu-data-tools. The following will be managed:

Namespace: `eu-data-tools`

- kafka
  - brokers: `fchu-prif-xknp1.autodatacorp.org:31050,fchu-prif-xknp2.autodatacorp.org:31050,fchu-prif-xknp3.autodatacorp.org:31050`
- elastic
  - elasticsearch:
    - https://eu-data-es.fcaus-f-storage.autodata.tech/
    - https://fchu-prif-xknp1.autodatacorp.org:31090
  - kibana: https://eu-data.fcaus-f-storage.autodata.tech/
- akhq - _(optional)_ https://eu-data-akhq.fcaus-f-storage.autodata.tech/

The deployment order is:

1. `./init`
1. `./elastic`
1. `./elastic-setup`
   - requires to wait until elastic is accessible to send api requests to setup various data streams
   - requires to wait until kibana is accessible to send api requests to setup various data views
1. `./kafka`
1. `./kafka-akhq`

---

# NodePorts

| Resource   | Ports |
|:-----------|:------|
| `elastic`  | `31090` |
| `kafka`    | `31030`,`3102[1-3]` |

# Logging & Monitoring

* Logs
  * [All](https://logging.fcaus-f-storage.autodata.tech/goto/f4d048b0-5019-11ef-8200-e9b2d2d7ebad)
  * [Elastic](https://logging.fcaus-f-storage.autodata.tech/goto/0a8a43e0-501a-11ef-8200-e9b2d2d7ebad)
  * [Kafka-Strimzi](https://logging.fcaus-f-storage.autodata.tech/goto/223cdac0-501a-11ef-8200-e9b2d2d7ebad)
  * [Zookeeper](https://logging.fcaus-p-storage.autodata.tech/goto/39a940e0-501a-11ef-8200-e9b2d2d7ebad)
  * [Kafka](https://logging.fcaus-p-storage.autodata.tech/goto/5208b990-501a-11ef-8200-e9b2d2d7ebad)
* Grafana
  * [Namespace Resources](https://grafana.fcaus-f-storage.autodata.tech/d/85a562078cdf77779eaa1add43ccec1e/kubernetes-compute-resources-namespace-pods?orgId=1&refresh=10s&var-datasource=prometheus&var-cluster=&var-namespace=eu-data-tools)