#!/usr/bin/env bash

# Function: Prompts the user to select an OS image from a multi-level menu.
# Sets the OSIMAGE global variable upon successful selection.
select_os_image() {
  echo ""
  echo "--- Select OS Category ---"
  select category_opt in "Linux" "Windows"; do
      case $REPLY in
          1) # Linux
              echo ""
              echo "--- Select Linux Distribution ---"
              select linux_distro_opt in "Ubuntu" "Debian" "Oracle Linux" "RedHat" "CentOS"; do
                  case $REPLY in
                      1) # Ubuntu
                          echo ""
                          echo "--- Select Ubuntu Version ---"
                          select ubuntu_version_opt in "Ubuntu 16.04" "Ubuntu 18.04" "Ubuntu 20.04" "Ubuntu 22.04" "Ubuntu 24.04"; do
                              case $REPLY in
                                  1) OSIMAGE=$UBUNTU_16; break 2 ;;
                                  2) OSIMAGE=$UBUNTU_18; break 2 ;;
                                  3) OSIMAGE=$UBUNTU_20; break 2 ;;
                                  4) OSIMAGE=$UBUNTU_22; break 2 ;;
                                  5) OSIMAGE=$UBUNTU_24; break 2 ;;
                                  *) echo "Invalid selection. Please choose a number from 1 to 5." ;;
                              esac
                          done
                          break ;; # Break from linux_distro_opt select loop
                      2) # Debian
                          echo ""
                          echo "--- Select Debian Version ---"
                          select debian_version_opt in "Debian 10" "Debian 11" "Debian 12"; do
                              case $REPLY in
                                  1) OSIMAGE=$DEBIAN_10; break 2 ;;
                                  2) OSIMAGE=$DEBIAN_11; break 2 ;;
                                  3) OSIMAGE=$DEBIAN_12; break 2 ;;
                                  *) echo "Invalid selection. Please choose a number from 1 to 3." ;;
                              esac
                          done
                          break ;; # Break from linux_distro_opt select loop
                      3) # Oracle Linux
                          echo ""
                          echo "--- Select Oracle Linux Version ---"
                          select oracle_version_opt in "Oracle Linux 7.9" "Oracle Linux 8.9 LVM" "Oracle Linux 9 LVM" "Oracle Linux 9.5 LVM"; do
                              case $REPLY in
                                  1) OSIMAGE=$ORACLE_79; break 2 ;;
                                  2) OSIMAGE=$ORACLE_89_LVM; break 2 ;;
                                  3) OSIMAGE=$ORACLE_9_LVM; break 2 ;;
                                  4) OSIMAGE=$ORACLE_95_LVM; break 2 ;;
                                  *) echo "Invalid selection. Please choose a number from 1 to 4." ;;
                              esac
                          done
                          break ;; # Break from linux_distro_opt select loop
                      4) # RedHat
                          echo ""
                          echo "--- Select RedHat Version ---"
                          select rhel_version_opt in "RHEL 7.9" "RHEL 7 LVM" "RHEL 8" "RHEL 8 LVM" "RHEL 8.10" "RHEL 9 LVM" "RHEL 9.6" "RHEL 10 LVM" "RHEL 10.0"; do
                              case $REPLY in
                                  1) OSIMAGE=$RHEL_79; break 2 ;;
                                  2) OSIMAGE=$RHEL_7_LVM; break 2 ;;
                                  3) OSIMAGE=$RHEL_8; break 2 ;;
                                  4) OSIMAGE=$RHEL_8_LVM; break 2 ;;
                                  5) OSIMAGE=$RHEL_810; break 2 ;;
                                  6) OSIMAGE=$RHEL_9_LVM; break 2 ;;
                                  7) OSIMAGE=$RHEL_96; break 2 ;;
                                  8) OSIMAGE=$RHEL_10_LVM; break 2 ;;
                                  9) OSIMAGE=$RHEL_100; break 2 ;;
                                  *) echo "Invalid selection. Please choose a number from 1 to 9." ;;
                              esac
                          done
                          break ;; # Break from linux_distro_opt select loop
                      5) # CentOS
                          echo ""
                          echo "--- Select CentOS Version ---"
                          select centos_version_opt in "CentOS 7.9" "CentOS 7 LVM" "CentOS 8.5" "CentOS 8 LVM"; do
                              case $REPLY in
                                  1) OSIMAGE=$CENTOS_79; break 2 ;;
                                  2) OSIMAGE=$CENTOS_7_LVM; break 2 ;;
                                  3) OSIMAGE=$CENTOS_85; break 2 ;;
                                  4) OSIMAGE=$CENTOS_8_LVM; break 2 ;;
                                  *) echo "Invalid selection. Please choose a number from 1 to 4." ;;
                              esac
                          done
                          break ;; # Break from linux_distro_opt select loop
                      *) echo "Invalid selection. Please choose a number from 1 to 5." ;;
                  esac
              done
              break ;; # Break from category_opt select loop
          2) # Windows
              echo ""
              echo "--- Select Windows Server Version ---"
              select windows_version_opt in "Windows Server 2016" "Windows Server 2019" "Windows Server 2022" "Windows Server 2025"; do
                  case $REPLY in
                      1) OSIMAGE=$WIN_2016; break 2 ;;
                      2) OSIMAGE=$WIN_2019; break 2 ;;
                      3) OSIMAGE=$WIN_2022; break 2 ;;
                      4) OSIMAGE=$WIN_2025; break 2 ;;
                      *) echo "Invalid selection. Please choose a number from 1 to 4." ;;
                  esac
              done
              break ;; # Break from category_opt select loop
          *) echo "Invalid selection. Please choose a number from 1 to 2." ;;
      esac
  done
}


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