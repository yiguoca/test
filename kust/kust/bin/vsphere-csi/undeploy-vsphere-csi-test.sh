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

if ! kubectl get namespace vsphere-csi-test &> /dev/null; then 
  echo "[INFO] Namespace 'vsphere-csi-test' does not exist, nothing to undeploy.";
  exit 0;
fi

echo "[INFO] Undeploying vSphere CSI test environment in namespace 'vsphere-csi-test'."
${CI_PROJECT_DIR}/build-with-plugins.sh $CSI_TEST_PATH | kubectl delete -f - 2>&1 | sed /unchanged/d