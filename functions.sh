#!/bin/bash

create_resource_group() {
  local rg_name=$1
  local location=$2
  az group create -n ${rg_name} -l ${location}
}

create_vnet() {
  local rg_name=$1
  local vnet_name=$2
  local subnet_name=$3
  local location=$4
  az network vnet create \
    --resource-group ${rg_name} \
    --name ${vnet_name} \
    --location ${location} \
    --address-prefix "10.0.0.0/16" \
    --subnet-name ${subnet_name} \
    --subnet-prefix "10.0.1.0/24"
}

update_subnet_with_nsg() {
  local rg_name=$1
  local vnet_name=$2
  local subnet_name=$3
  local nsg_name=$4
  az network vnet subnet update \
    --resource-group ${rg_name} \
    --vnet-name ${vnet_name} \
    --name ${subnet_name} \
    --network-security-group ${nsg_name}
}

create_vm() {
  local rg_name=$1
  local vm_name=$2
  local location=$3
  local os_image=$4
  local username=$5
  local password=$6
  local vnet_name=$7
  local subnet_name=$8
  local nsg_name=$9
  az vm create \
    --resource-group ${rg_name} \
    --name ${vm_name} \
    --location ${location} \
    --image ${os_image} \
    --size Standard_E2ds_v6 \
    --admin-username ${username} \
    --admin-password ${password} \
    --public-ip-sku standard \
    --vnet-name ${vnet_name} \
    --subnet ${subnet_name} \
    --nsg ${nsg_name} \
    --enable-agent true \
    --enable-auto-update true \
    --patch-mode AutomaticByPlatform
}

enable_boot_diagnostics() {
  local rg_name=$1
  local vm_name=$2
  az vm boot-diagnostics enable --resource-group ${rg_name} --name ${vm_name}
}
