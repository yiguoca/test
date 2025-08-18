# rke2-ingress-nginx-controller

## how to upgrade the helm chart
Delete the contents of the charts folder, download the version of the helm chart you want to use from rancher's github, and extract it into the charts folder.
Double-check the values provided in the kustomization.yaml work with the new version of the chart.  If not, update the values in the kustomization.yaml file.

Example extraction of helm chart:
```bash
cd cluster/test/kube-system/rke2-ingress-nginx-controller
# remove the contents of the charts folder
rm -rf charts/*
tar xf rke2-ingress-nginx-4.5.201.tgz -C charts
```


## References
rancher helm chart assets for rke2-ingress-nginx: https://github.com/rancher/rke2-charts/tree/main/assets/rke2-ingress-nginx
