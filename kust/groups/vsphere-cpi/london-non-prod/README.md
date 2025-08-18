This manages the distribution of the [vSphere Cloud Provider Interface (CPI)] driver(s) on the `kube-system` namespace. We are expanding on the [base definition](/bases/vsphere-cpi/) to work within the london clusters.

----

## Secrets

|Name| SecretId | Generator | Description |
|:---|----------|:----------|:------------|
| `vsphere-cloud-london-nonprod-secret` | [`12208`] | [`ThycoticSecretGenerator`] | provides the credentials needed for the cpi to connect to our vcenter. |

We use the secret generator to generate a secret that will contain the following information:

```
<host>.password
<host>.username
```

The `<host>` should be your vcenter host, which in this case should be `lops-prif-vcsa1.autodatacorp.org`.

[`12208`]: https://autodata.secretservercloud.com/app/#/secrets/12208/general
[`ThycoticSecretGenerator`]: /plugin/fca.autodata.net/v1/thycoticsecretgenerator

## Patches

- we patch in some labels to `vsphere-cloud-london-nonprod-secret` to make it more uniform
- we delete the reference to the example secret `vsphere-cloud-secret` for some housekeeping
- we provide our `vsphere.conf` to the configmap `vsphere-cloud-config`

## FAQ

#### Why do we need the secret ref in the global and vcenter definitions?

In the [patch](./patches/vsphere-cloud-config-patch.yaml) we define a reference to the secret `vsphere-cloud-london-nonprod-secret` in the `global` and `vcenter`; this is mainly because of the [example](https://github.com/kubernetes/cloud-provider-vsphere/blob/master/releases/README.md#step-2-edit-the-secret-and-configmap-inside-vsphere-cloud-controller-manageryaml) shows it can be setup in both. I am unsure if the global will be used or not so I kept it there. We may want to remove it once we know for sure.