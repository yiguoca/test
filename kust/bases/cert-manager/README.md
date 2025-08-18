# cert-manager

## Helm Deployment notes
The helm charts contain reference to `.Release.Namespace` in some cases, which requires a namepace to be specified when passing this to helm, hence the desired namespace may need to be set as default when building (either locally or in ci).  Recommend unsetting the `KUBECONFIG`, unsetting the namespace being set in the context (so that the default can be taken from the helm chart), or setting the `KUBECONFIG` context to the desired default before rendering the kustomization.

## Upgrade helm charts

To upgrade the charts being referenced, please do the following:
- remove the [charts](charts)` folder
- update the `helmCharts` versions you need updated in the [kustomization.yaml](kustomization.yaml)
- re-render the charts folder using `./build-with-plugins.sh bases/cert-manager`
- git add and commit the [charts](charts) folder to pick up the changes
