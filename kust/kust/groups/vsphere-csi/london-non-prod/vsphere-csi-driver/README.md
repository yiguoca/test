This manages the distribution of the [VSphere Container Storage Interface (CSI)] driver(s). We are expanding on the [base definition](/bases/vsphere-csi/vsphere-cpi/) to work within the london test infrastructure cluster.

----

## Secrets

|Name| SecretId | Generator | Description |
|:---|----------|:----------|:------------|
| `vsphere-config-secret` | [`12208`] | [`ThycoticVSphereCsiSecretGenerator`] | provides the credentials and configuration file to the driver. |


[`12208`]: https://autodata.secretservercloud.com/app/#/secrets/12208/general
[`ThycoticVSphereCsiSecretGenerator`]: /plugin/fca.autodata.net/v1/thycoticvspherecsisecretgenerator/