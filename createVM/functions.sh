#!/usr/bin/env bash

# Function: Ensure a resource group exists, or create it if it doesn't.
# Arguments:
#   $1: Resource group name
#   $2: Location
ensure_resource_group() {
  local rg_name=$1
  local location=$2
  if ! az group show -g "$rg_name" &>/dev/null; then
    echo "Resource Group '$rg_name' not found. Creating in '$location'..."
    az group create -g "$rg_name" -l "$location" --output none || { echo "Error: Failed to create resource group '$rg_name'."; return 1; }
    echo "Resource Group '$rg_name' created successfully."
  else
    echo "Resource Group '$rg_name' already exists."
  fi
}

# Function: Ensure a VNet and subnet exist, or create them if they don't.
# Arguments:
#   $1: Resource group name
#   $2: VNet name
#   $3: Subnet name
#   $4: Location
ensure_vnet() {
  local rg_name=$1
  local vnet_name=$2
  local subnet_name=$3
  local location=$4
  if ! az network vnet show --resource-group "$rg_name" --name "$vnet_name" &>/dev/null; then
    echo "Virtual Network '$vnet_name' not found. Creating with subnet '$subnet_name' (10.0.0.0/24)..."
    az network vnet create \
        --resource-group "$rg_name" \
        --name "$vnet_name" \
        --location "$location" \
        --address-prefixes 10.0.0.0/16 \
        --subnet-name "$subnet_name" \
        --subnet-prefixes 10.0.0.0/24 \
        --output none || { echo "Error: Failed to create VNet '$vnet_name' and subnet '$subnet_name'."; return 1; }
    echo "Virtual Network '$vnet_name' and subnet '$subnet_name' created successfully."
  else
    echo "Virtual Network '$vnet_name' already exists."
  fi
}

# Function: Create a Virtual Machine and associate NSG to its NIC.
# Arguments:
#   $1: Resource group name
#   $2: VM name
#   $3: Location
#   $4: OS image URN
#   $5: Admin username
#   $6: Admin password
#   $7: VNet name
#   $8: Subnet name
#   $9: NSG name or ID
#   $10: VM size (SKU)
create_vm() {
  local rg_name=$1
  local vm_name=$2
  local location=$3
  local os_image=$4
  local username=$5
  local password=$6
  local vnet_name=$7
  local subnet_name=$8
  local nsg_name=$9      # Use the 9th argument for the NSG
  local vm_size=${10}

  echo "Attaching NSG '$nsg_name' to the VM's NIC upon creation..."
  az vm create \
    --resource-group "${rg_name}" \
    --name "${vm_name}" \
    --location "${location}" \
    --image "${os_image}" \
    --size "${vm_size}" \
    --admin-username "${username}" \
    --admin-password "${password}" \
    --public-ip-sku Standard \
    --vnet-name "${vnet_name}" \
    --subnet "${subnet_name}" \
    --nsg "${nsg_name}" \
    --enable-agent true \
    --enable-auto-update true \
    --patch-mode AutomaticByPlatform \
    --output none || { echo "Error creating VM."; return 1; }
}

# Function: Enable boot diagnostics for a VM.
# Arguments:
#   $1: Resource group name
#   $2: VM name
enable_boot_diagnostics() {
  local rg_name=$1
  local vm_name=$2
  az vm boot-diagnostics enable \
    --resource-group "${rg_name}" \
    --name "${vm_name}" \
    --output none || { echo "Warning: Failed to enable boot diagnostics."; return 1; }
}