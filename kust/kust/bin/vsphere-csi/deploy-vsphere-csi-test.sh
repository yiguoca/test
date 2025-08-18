#!/bin/bash

function command_exists() {
  type "$1" &> /dev/null
}

#-------------------------------------------------------------------------------

if ! command_exists kubectl; then
  echo "[ERROR] command 'kubectl' does not exist, unable to continue with execution. Aborting.";
  exit 1;
fi

if ! command_exists kustomize; then
  echo "[ERROR] command 'kustomize' does not exist, unable to continue with execution. Aborting.";
  exit 1;
fi

if ! command_exists grep; then
  echo "[ERROR] command 'grep' does not exist, unable to continue with execution. Aborting.";
  exit 1;
fi

if [ ! -f "${CI_PROJECT_DIR}/build-with-plugins.sh" ]; then
  echo "[ERROR] build-with-plugins.sh not found in ${CI_PROJECT_DIR}. Aborting.";
  exit 1;
fi

if [ -z "$CSI_TEST_PATH" ]; then 
    echo "[ERROR] CSI_TEST_PATH is not set. Aborting.";
    exit 1; 
fi

if [ ! -d "$CSI_TEST_PATH" ]; then 
    echo "[ERROR] CSI_TEST_PATH is not a directory; CSI_TEST_PATH='${CSI_TEST_PATH}'. Aborting.";
    exit 1; 
fi

#-------------------------------------------------------------------------------

# verify there is atleast 1 node with the label storage/vsphere=true
echo "[INFO] Validating the state of the cluster is capable of deploying the vSphere CSI test environment."
if [ -z "$(kubectl get nodes -l storage/vsphere=true -o jsonpath='{.items[*].metadata.name}' 2> /dev/null)" ]; then
  echo "[ERROR] There are no nodes with the label storage/vsphere=true"
  exit 1
fi

echo "[INFO] Deploying vSphere CSI test environment in namespace 'vsphere-csi-test' to test the vSphere CSI driver configurations."
${CI_PROJECT_DIR}/build-with-plugins.sh $CSI_TEST_PATH | kubectl apply -f - 2>&1 | sed /unchanged/d

if [ $? -ne 0 ]; then
  echo "[ERROR] Failed to deploy vSphere CSI test environment. Aborting.";
  exit 1;
fi

# need to modify the statefulset test-node to have the number of replacas match the number of nodes with label storage/vsphere=true
echo "[INFO] Modifying the statefulset test-node to match the number of nodes with label storage/vsphere=true"
REPLICAS=$(kubectl get nodes -l storage/vsphere=true -o jsonpath='{.items[*].metadata.name}' | wc -w)
echo "[INFO] setting the number of replicas to $REPLICAS"
kubectl patch statefulset -l app.kubernetes.io/component==test-vsphere-csi-operations -n vsphere-csi-test --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value": '$REPLICAS'}]'

# We need to wait a bit to see when the pod is ready to start containers; we ignore the error this is because the pod may never 
# run because the node failed its test. This acts as an indicator that something is wrong environmentally.
echo "[INFO] Waiting for the test-node statefulset to be ready"

kubectl rollout status statefulset -l app.kubernetes.io/component==test-vsphere-csi-operations -n vsphere-csi-test --timeout=3m || true

# if any of the pods returned by the selector are not running then we will fail the job
if ! kubectl get pods -n vsphere-csi-test -l app.kubernetes.io/component==test-vsphere-csi-operations \
  -o jsonpath='{range .items[*]}{.metadata.name} {.status.phase}{"\n"}{end}' \
  | awk '$2 != "Running"' | grep -q .; then
  echo "[INFO] All pods are Running."
  kubectl get pods -n vsphere-csi-test -l app.kubernetes.io/component==test-vsphere-csi-operations
else
  echo "[ERROR] Some nodes failed their tests. Check logs for more info."
  kubectl get pods -n vsphere-csi-test -l app.kubernetes.io/component==test-vsphere-csi-operations \
    --field-selector=status.phase!=Running \
    -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
  exit 1
fi

echo "[INFO] vSphere CSI test environment deployed successfully in namespace 'vsphere-csi-test'."