Contains all the ssl [generators] to be shared across the chaska-storage cluster
for namespaces that need them. The intention is to help manage certificate update
rollouts to a single location for a cluster.

| Secret Id | Cert |
|:----------|:-----|
| [`5890`]  | `*.fcaus-f-storage.autodata.tech` |


[generators]: ./generators/
[`5890`]: https://autodata.secretservercloud.com/app/#/secrets/5890/general
