#!/bin/bash
# Installs all compliance-toolkit helm charts
# Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=compliance-toolkit
CHART_VERSION=1.0.0

echo Create $NS namespace
kubectl create ns $NS

function installing_compliance-toolkit-batchjob() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite
  helm repo add mosip https://mosip.github.io/mosip-helm
  helm repo update

  echo Copy configmaps
  ./copy_cm.sh

  echo Installing compliance-toolkit-batch-job
  helm -n $NS install compliance-toolkit-batch-job mosip/compliance-toolkit-batch-job --version $CHART_VERSION

  kubectl -n $NS  get deploy -o name |  xargs -n1 -t  kubectl -n $NS rollout status

  echo Installed compliance-toolkit-batchjob service
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
installing_compliance-toolkit-batchjob   # calling function
