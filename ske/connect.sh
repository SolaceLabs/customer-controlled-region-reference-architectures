#!/bin/bash

TMPDIR=`pwd`/.tmp
mkdir -p ${TMPDIR}

while [[ -n "$1" ]]; do
  case "$1" in
    --socks-port)
      SOCKS_PORT=$2
      shift
      ;;
    --private-key)
      PRIVATE_KEY="-i $2"
      shift
      ;;
  esac
  shift
done

rm -f ${TMPDIR}/kubeconfig
export KUBECONFIG=${TMPDIR}/kubeconfig

PROJECT_ID=$(terraform output -raw -state=terraform/terraform.tfstate project_id)
CLUSTER_NAME=$(terraform output -raw -state=terraform/terraform.tfstate cluster_name)

stackit ske kubeconfig create ${CLUSTER_NAME} --project-id ${PROJECT_ID}

PUBLIC_API=$(terraform output -raw -state=terraform/terraform.tfstate kubernetes_api_public_access)

if [[ $PUBLIC_API == "false" ]]; then
  SOCKS_PORT="${SOCKS_PORT:-4321}"

  BASTION_USERNAME=$(terraform output -raw -state=terraform/terraform.tfstate bastion_username)
  BASTION_PUBLIC_IP=$(terraform output -raw -state=terraform/terraform.tfstate bastion_public_ip)

  echo "creating ssh tunnel to ${BASTION_PUBLIC_IP}"
  ssh ${PRIVATE_KEY} ${BASTION_USERNAME}@${BASTION_PUBLIC_IP} -oStrictHostKeyChecking=no -D ${SOCKS_PORT} -fN

  SOCKS_URL="socks5://localhost:${SOCKS_PORT}" yq e -i '.clusters[0].cluster.proxy-url = env(SOCKS_URL)' ${KUBECONFIG}
fi
