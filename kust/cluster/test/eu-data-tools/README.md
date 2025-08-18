Defines the kustomizations for setting up supporting infrastructure for the
eu-data-tools. The following will be managed:

Namespace: `eu-data-tools`

- kafka
  - brokers: `lchu-teif-xkn01.autodatacorp.org:30050,lchu-teif-xkn02.autodatacorp.org:30050,lchu-teif-xkn03.autodatacorp.org:30050`
- elastic
  - elasticsearch: https://eu-data-es.fcaus-te.autodata.tech/
  - kibana: https://eu-data.fcaus-te.autodata.tech/
- amqp
  - management-ui: https://eu-data-rabbitmq.fcaus-te.autodata.tech
  - host: `rabbitmq.eu-data-tools.svc`
- akhq - _(optional)_ https://eu-data-akhq.fcaus-te.autodata.tech/

The deployment order is:

1. `./init`
1. `./elastic`
1. `./elastic-setup`
   - requires to wait until elastic is accessible to send api requests to setup various data streams
   - requires to wait until kibana is accessible to send api requests to setup various data views
1. `./kafka`
1. `./kafka-akhq`
1. `./amqp`
