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

echo "[INFO] validating the state of the cluster is capable of deploying the vSphere CSI driver."
# verify there is atleast 1 node with the label storage/vsphere=true
if [ -z "$(kubectl get nodes -l storage/vsphere=true -o jsonpath='{.items[*].metadata.name}' 2> /dev/null)" ]; then
  echo "[ERROR] There are no nodes with the label storage/vsphere=true"
  exit 1
fi

# verify that the vsphere-cpi is deployed and running;
if [ ! -z "${ENABLE_CPI_REQUIRED}" ]; then
  echo "[INFO] Checking if the vSphere Cloud Provider Interface (CPI) is deployed and running."

  if [ -z "$(kubectl get pods -n kube-system -l name==vsphere-cloud-controller-manager -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2> /dev/null)" ]; then 
      echo "[ERROR] The vsphere-cpi is not running"; 
      exit 1; 
  fi
fi

echo "[INFO] Deploying vSphere CSI driver components in namespace 'vmware-system-csi'."
# deploy the components of the vsphere-csi
${CI_PROJECT_DIR}/build-with-plugins.sh $CSI_DRIVER_PATH | kubectl apply -f - 2>&1 | sed /unchanged/d
kubectl wait --for=condition=ready --timeout=3m -n vmware-system-csi pod -l app==vsphere-csi-node
kubectl wait --for=condition=ready --timeout=3m -n vmware-system-csi pod -l app==vsphere-csi-controller

echo "[INFO] Deploying the various storage resources required to utilize the csi driver (ex: storage classes, volumesnapshotclasses, etc)."
# deploy the storage classes and volumesnapshotclasses etc
${CI_PROJECT_DIR}/build-with-plugins.sh $CSI_STORAGE_PATH | kubectl apply -f - 2>&1 | sed /unchanged/d

echo "[INFO] vSphere CSI driver and its associated resources deployed successfully."