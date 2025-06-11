#!/bin/bash

# Load variables and functions
source .env
source ./images.sh
source ./functions.sh

# Function to confirm or change subscription
confirm_subscription() {
  current_subscription=$(az account show --query "id" -o tsv)
  echo "Current default subscription: $current_subscription"
  read -p "Is this the correct subscription? (y/n): " confirm
  if [[ $confirm != "y" ]]; then
    read -p "Please enter the correct subscription ID: " new_subscription
    az account set --subscription $new_subscription
    echo "Subscription set to $new_subscription"
  else
    echo "Using default subscription: $current_subscription"
  fi
}

# Parse command-line arguments
while getopts "n:g:l:v:s:i:N:S:" opt; do
  case ${opt} in
    n) VMNAME=${OPTARG} ;;
    g) RGNAME=${OPTARG} ;;
    l) LOCATION=${OPTARG} ;;
    v) VNETNAME=${OPTARG} ;;
    s) SUBNETNAME=${OPTARG} ;;
    i) OSIMAGE=${OPTARG} ;;
    N) NSGNAME=${OPTARG} ;;
    S) SUBSCRIPTION=${OPTARG} ;;
    *) echo "Invalid option: -${OPTARG}" ;;
  esac
done

# Confirm or set subscription
confirm_subscription

# Prompt for missing values
[ -z "$VMNAME" ] && read -p "Enter VM name: " VMNAME
[ -z "$RGNAME" ] && read -p "Enter Resource Group name: " RGNAME
[ -z "$LOCATION" ] && read -p "Enter location (e.g., japaneast): " LOCATION
[ -z "$VNETNAME" ] && read -p "Enter VNet name (default: ${RGNAME}Vnet): " VNETNAME
VNETNAME=${VNETNAME:-${RGNAME}Vnet}
[ -z "$SUBNETNAME" ] && read -p "Enter Subnet name (default: ${RGNAME}Subnet): " SUBNETNAME
SUBNETNAME=${SUBNETNAME:-${RGNAME}Subnet}

# OS image selection
if [ -z "$OSIMAGE" ]; then
  echo "Select OS image:"
  select opt in "Ubuntu 22.04" "Debian 12" "Oracle Linux 9.5" "Windows Server 2022"; do
    case $REPLY in
      1) OSIMAGE=$UBUNTU_22; break ;;
      2) OSIMAGE=$DEBIAN_12; break ;;
      3) OSIMAGE=$ORACLE_95; break ;;
      4) OSIMAGE=$WIN_2022; break ;;
      *) echo "Please select a valid option." ;;
    esac
  done
fi

[ -z "$NSGNAME" ] && read -p "Enter NSG resource ID (optional): " NSGNAME

# Create resources
create_resource_group ${RGNAME} ${LOCATION}
create_vnet ${RGNAME} ${VNETNAME} ${SUBNETNAME} ${LOCATION}

if [ -n "$NSGNAME" ]; then
  update_subnet_with_nsg ${RGNAME} ${VNETNAME} ${SUBNETNAME} ${NSGNAME}
fi

create_vm ${RGNAME} ${VMNAME} ${LOCATION} ${OSIMAGE} ${USERNAME} ${PASSWORD} ${VNETNAME} ${SUBNETNAME} ${NSGNAME}
enable_boot_diagnostics ${RGNAME} ${VMNAME}

