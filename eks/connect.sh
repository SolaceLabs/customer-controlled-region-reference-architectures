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

aws eks update-kubeconfig --region $(terraform output -raw -state=terraform/terraform.tfstate region) --name $(terraform output -raw -state=terraform/terraform.tfstate cluster_name)

PUBLIC_API=$(terraform output -raw -state=terraform/terraform.tfstate kubernetes_api_public_access)

if [[ $PUBLIC_API == "false" ]]; then
  SOCKS_PORT="${SOCKS_PORT:-4321}"
  
  BASTION_PUBLIC_IP=`terraform output -raw -state=terraform/terraform.tfstate bastion_public_ip`

  echo "creating ssh tunnel to ${BASTION_PUBLIC_IP}"
  ssh ${PRIVATE_KEY} ec2-user@${BASTION_PUBLIC_IP} -oStrictHostKeyChecking=no -D ${SOCKS_PORT} -fN

  SOCKS_URL="socks5://localhost:${SOCKS_PORT}" yq e -i '.clusters[0].cluster.proxy-url = env(SOCKS_URL)' ${KUBECONFIG}
fi