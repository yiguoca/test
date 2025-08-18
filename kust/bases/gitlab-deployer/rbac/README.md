# deployer RBAC
A service account intended to have permission to update the namespaces for deploying to the fcaus-f Chaska kubernetes cluster.

The following steps assume that `./build-with-plugins.sh bases/gitlab-deployer/rbac|kubectl apply -f -` has been run to install `default` `Namespace` with the required `deployer` **RBAC** (`deployer` ServiceAccount and ClusterRoleBinding).

## Generate a kubeconfig file for use with CI

With your KUBECONFIG configured to use a config that already has access to the cluster, create a new config file
Note: The following example is what was used for generating the fcaus-example scoped kubernetes config)
```bash
#!/bin/bash

# Set variables
CLUSTER_NAME="fcaus-example"
SERVICEACCOUNT_NAME="deployer"
KUBEAPI="https://kubeapi.fcaus-example.autodata.tech:6443/"
DEPLOYER_KUBECONFIG_PATH="$CLUSTER_NAME-$SERVICEACCOUNT_NAME.config"
CA_CERT_PATH="$CLUSTER_NAME-$SERVICEACCOUNT_NAME-ca.crt" # Path to your CA certificate

# Step 1: Generate the Deployer Token

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $SERVICEACCOUNT_NAME-token
  annotations:
    kubernetes.io/service-account.name: $SERVICEACCOUNT_NAME
type: kubernetes.io/service-account-token
EOF

DEPLOYER_TOKEN=$(kubectl get secret -o jsonpath="{.data.token}" -n default $SERVICEACCOUNT_NAME-token | base64 --decode)

kubectl -n default get secret $SERVICEACCOUNT_NAME-token -o jsonpath="{.data.ca\.crt}" | base64 --decode > $CA_CERT_PATH

# Step 2: Configure kubeconfig
kubectl --kubeconfig $DEPLOYER_KUBECONFIG_PATH config set-cluster $CLUSTER_NAME \
  --embed-certs=true \
  --server=$KUBEAPI \
  --certificate-authority=$CA_CERT_PATH

kubectl --kubeconfig $DEPLOYER_KUBECONFIG_PATH config set-credentials $SERVICEACCOUNT_NAME --token=$DEPLOYER_TOKEN

kubectl --kubeconfig $DEPLOYER_KUBECONFIG_PATH config set-context $SERVICEACCOUNT_NAME \
  --cluster=$CLUSTER_NAME \
  --user=$SERVICEACCOUNT_NAME

kubectl --kubeconfig $DEPLOYER_KUBECONFIG_PATH config use-context $SERVICEACCOUNT_NAME
```

### Test the new config file's access:

```bash
CLUSTER_NAME="fcaus-example" SERVICEACCOUNT_NAME="deployer" DEPLOYER_KUBECONFIG_PATH="$CLUSTER_NAME-$SERVICEACCOUNT_NAME.config" kubectl --kubeconfig $DEPLOYER_KUBECONFIG_PATH auth can-i get pods
```
expect `yes`

### Set CI variable to use this value
Export the config file that was generated in the above steps to a CI Variable that can be pulled into your CI job.
