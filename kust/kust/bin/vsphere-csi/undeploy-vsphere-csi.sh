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

if ! command_exists jq; then
  echo "[ERROR] command 'jq' does not exist, unable to continue with execution. Aborting.";
  exit 1;
fi

if [ ! -f "${CI_PROJECT_DIR}/build-with-plugins.sh" ]; then
  echo "[ERROR] build-with-plugins.sh not found in ${CI_PROJECT_DIR}. Aborting.";
  exit 1;
fi

if [ -z "$CSI_DRIVER_PATH" ]; then 
    echo "[ERROR] CSI_DRIVER_PATH is not set. Aborting.";
    exit 1; 
elif [ ! -d "$CSI_DRIVER_PATH" ]; then 
    echo "[ERROR] CSI_DRIVER_PATH is not a directory; CSI_DRIVER_PATH='${CSI_DRIVER_PATH}'. Aborting.";
    exit 1;
fi

if [ -z "$CSI_STORAGE_PATH" ]; then 
    echo "[ERROR] CSI_STORAGE_PATH is not set. Aborting.";
    exit 1; 
elif [ ! -d "$CSI_STORAGE_PATH" ]; then 
    echo "[ERROR] CSI_STORAGE_PATH is not a directory; CSI_STORAGE_PATH='${CSI_STORAGE_PATH}'. Aborting.";
    exit 1;
fi

#-------------------------------------------------------------------------------

[ ! -z "$ERROR_ON_VSPHERE_PVC" ] && echo "[INFO] Detected ERROR_ON_VSPHERE_PVC, if any PersistentVolumes (PVs) have a storageclass with 'vsphere' in it, undeploying will fail."
[ ! -z "$DEBUG" ] && echo "[DEBUG] Checking for PVs with vsphere storageclass."
if kubectl get pv -o json 2>/dev/null | jq -e '.items[] | select(.spec.storageClassName | contains("vsphere"))' >/dev/null; then 
  if [ ! -z "$ERROR_ON_VSPHERE_PVC" ]; then 
    echo "[ERROR] There are still PVs with vsphere storageclasses."; 
  else 
    echo "[WARN] There are still PVs with vsphere storageclasses.";
  fi

  kubectl get pv | grep vsphere;

  [ ! -z "$ERROR_ON_VSPHERE_PVC" ] && exit 1; 
fi

if kubectl get storageclass -l app.kubernetes.io/part-of=vsphere-csi >/dev/null; then 
  echo "[INFO] Undeploying the various storage resources required to utilize the csi driver (ex: storage classes, volumesnapshotclasses, etc)."
  ${CI_PROJECT_DIR}/build-with-plugins.sh $CSI_STORAGE_PATH | kubectl delete -f - 2>&1 | sed /unchanged/d
else
  echo "[INFO] No storageclasses part of the vsphere-csi found, nothing to undeploy.";
fi

[ ! -z "$DEBUG" ] && echo "[DEBUG] waiting for 30 seconds to ensure all resources are cleaned up before undeploying the vSphere CSI driver components."
sleep 30

echo "[INFO] Undeploying vSphere CSI driver components in namespace 'vmware-system-csi'."
${CI_PROJECT_DIR}/build-with-plugins.sh $CSI_DRIVER_PATH | kubectl delete -f - 2>&1 | sed /unchanged/d