#!/usr/bin/env bash
set -euo pipefail

# Load environment variables and functions
source .env
source ./images.sh
source ./functions.sh

# --- Configuration Constants ---
DEFAULT_NSG="/subscriptions/7e276fb1-2960-4dfc-a5c7-5ecb4c8c51a6/resourceGroups/LabJason/providers/Microsoft.Network/networkSecurityGroups/common-nsg-japaneast"
DEFAULT_VM_SIZE="Standard_D2s_v3"
DEFAULT_RGNAME="lab"
DEFAULT_LOCATION="japaneast"

# --- Helper Functions ---

# Function to remove carriage returns from a string (expects string as argument)
strip_carriage_return() {
    # ${1} ensures that if the argument is null, it's treated as empty string, not unbound.
    echo "${1}" | tr -d '\r'
}

# Function: Confirm or switch Azure subscription
confirm_subscription() {
    local current_subscription_raw # Temporary variable to hold raw output
    current_subscription_raw=$(az account show --query id -o tsv) || { echo "Error: Could not get current Azure subscription. Please log in."; exit 1; }
    current_subscription=$(strip_carriage_return "$current_subscription_raw") # Pass output as argument
    echo "Current default subscription: $current_subscription"
    read -p "Is this the correct subscription? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        read -p "Please enter the correct subscription ID: " new_subscription
        az account set --subscription "$new_subscription" || { echo "Error: Failed to set subscription to $new_subscription."; exit 1; }
        echo "Subscription set to $new_subscription."
    else
        echo "Using default subscription: $current_subscription."
    fi
}

# --- Pre-flight Checks ---

# Check if USERNAME and PASSWORD are set in .env
if [[ -z "${USERNAME:-}" ]]; then
    echo "Error: USERNAME environment variable is not set. Please check your .env file."
    exit 1
fi
if [[ -z "${PASSWORD:-}" ]]; then
    echo "Error: PASSWORD environment variable is not set. Please check your .env file."
    exit 1
fi

# --- Main Script Logic ---

# Parse command-line arguments
while getopts ":n:g:l:v:s:i:N:z:S:" opt; do
    case $opt in
        n) VMNAME=$OPTARG ;;           # VM name
        g) RGNAME=$OPTARG ;;           # Resource Group name
        l) LOCATION=$OPTARG ;;         # Azure location
        v) VNETNAME=$OPTARG ;;         # VNet name
        s) SUBNETNAME=$OPTARG ;;       # Subnet name
        i) OSIMAGE=$OPTARG ;;          # OS image identifier
        N) NSGNAME=$OPTARG ;;          # NSG name or resource ID
        z) VMSIZE=$OPTARG ;;           # VM size (SKU)
        S) SUBSCRIPTION=$OPTARG ;;     # Optional: switch subscription
        *) echo "Invalid option: -$OPTARG" ; exit 1 ;;
    esac
done

# Confirm or switch subscription
confirm_subscription

echo "" # Add a blank line for better readability

# Prompt for Resource Group with default
read -p "Enter Resource Group name (default: ${DEFAULT_RGNAME}): " user_rgname
RGNAME=${user_rgname:-$DEFAULT_RGNAME}
echo "Using Resource Group: $RGNAME"

# Prompt for location with default
read -p "Enter location (default: ${DEFAULT_LOCATION}): " user_location
LOCATION=${user_location:-$DEFAULT_LOCATION}
echo "Using location: $LOCATION"

# Prompt for VM name if missing
if [[ -z "${VMNAME:-}" ]]; then
    read -p "Enter VM name: " VMNAME
    if [[ -z "${VMNAME:-}" ]]; then
        echo "Error: VM name cannot be empty. Exiting."
        exit 1
    fi
fi

# Prompt for VM size with default
read -p "Enter VM size (default: ${DEFAULT_VM_SIZE}): " user_vmsize
VMSIZE=${user_vmsize:-$DEFAULT_VM_SIZE}
echo "Using VM size: $VMSIZE"

# Set defaults for VNet and Subnet names if not provided via arguments
VNETNAME=${VNETNAME:-"${RGNAME}Vnet"}
SUBNETNAME=${SUBNETNAME:-"${RGNAME}Subnet"}

# --- Ensure Azure Resources Exist or Create Them ---

echo "--- Checking Azure Resources ---"

# Ensure Resource Group exists
if ! az group show -g "$RGNAME" &>/dev/null; then
    echo "Resource Group '$RGNAME' not found. Creating in '$LOCATION'..."
    az group create -g "$RGNAME" -l "$LOCATION" || { echo "Error: Failed to create resource group '$RGNAME'."; exit 1; }
    echo "Resource Group '$RGNAME' created successfully."
else
    echo "Resource Group '$RGNAME' already exists."
fi

# Ensure VNet and Subnet exist
if ! az network vnet show --resource-group "$RGNAME" --name "$VNETNAME" &>/dev/null; then
    echo "Virtual Network '$VNETNAME' not found in RG '$RGNAME'. Creating with subnet '$SUBNETNAME' (10.0.0.0/24)..."
    az network vnet create \
        --resource-group "$RGNAME" \
        --name "$VNETNAME" \
        --location "$LOCATION" \
        --address-prefixes 10.0.0.0/16 \
        --subnet-name "$SUBNETNAME" \
        --subnet-prefixes 10.0.0.0/24 || { echo "Error: Failed to create VNet '$VNETNAME' and subnet '$SUBNETNAME'."; exit 1; }
    echo "Virtual Network '$VNETNAME' and subnet '$SUBNETNAME' created successfully."
else
    echo "Virtual Network '$VNETNAME' and subnet '$SUBNETNAME' already exist."
fi

# Determine NSG to use
if [[ -n "${NSGNAME:-}" ]]; then
    NSGNAME=$(strip_carriage_return "$NSGNAME")
    echo "Using specified NSG: $NSGNAME"
elif [[ "$RGNAME" == "$DEFAULT_RGNAME" ]]; then
    NSGNAME=$(strip_carriage_return "$DEFAULT_NSG")
    echo "Using default NSG: $NSGNAME"
else
    local_nsg_name="${RGNAME}-nsg"
    echo "NSG not provided. Creating NSG '$local_nsg_name' in RG '$RGNAME'..."
    az network nsg create \
        --resource-group "$RGNAME" \
        --name "$local_nsg_name" \
        --location "$LOCATION" || { echo "Error: Failed to create NSG '$local_nsg_name'."; exit 1; }

    # Capture output first, then strip carriage return
    # local new_nsg_id_raw
    new_nsg_id_raw=$(az network nsg show --resource-group "$RGNAME" --name "$local_nsg_name" --query id -o tsv)
    NSGNAME=$(strip_carriage_return "$new_nsg_id_raw")
    echo "New NSG '$local_nsg_name' created and will be used: $NSGNAME"
fi

echo "--- NSG Association ---"
# Apply NSG to the subnet
echo "Associating NSG with subnet '${SUBNETNAME}' in VNet '${VNETNAME}'..."
az network vnet subnet update \
    --resource-group "${RGNAME}" \
    --vnet-name "${VNETNAME}" \
    --name "${SUBNETNAME}" \
    --network-security-group "${NSGNAME}" || { echo "Error: Failed to associate NSG '$NSGNAME' with subnet '$SUBNETNAME'."; exit 1; }
echo "NSG successfully associated with subnet."

# --- OS Image Selection ---
if [[ -z "${OSIMAGE:-}" ]]; then
    echo "" # Blank line
    echo "--- Select OS Image ---"
    select opt in "Ubuntu 22.04" "Debian 12" "Oracle Linux 9.5" "Windows Server 2022"; do
        case $REPLY in
            1) OSIMAGE=$UBUNTU_22; break ;;
            2) OSIMAGE=$DEBIAN_12; break ;;
            3) OSIMAGE=$ORACLE_95; break ;;
            4) OSIMAGE=$WIN_2022; break ;;
            *) echo "Invalid selection. Please choose a number from 1 to 4." ;;
        esac
    done
    echo "Selected OS Image: $OSIMAGE"
fi

# --- VM Creation ---
echo "" # Blank line
echo "--- Creating Virtual Machine ---"
create_vm \
    "$RGNAME" \
    "$VMNAME" \
    "$LOCATION" \
    "$OSIMAGE" \
    "$USERNAME" \
    "$PASSWORD" \
    "$VNETNAME" \
    "$SUBNETNAME" \
    "$NSGNAME" \
    "$VMSIZE" || { echo "Error: Failed to create VM '$VMNAME'."; exit 1; }
echo "Virtual Machine '$VMNAME' created successfully."

# --- Enable Boot Diagnostics ---
echo "" # Blank line
echo "--- Enabling Boot Diagnostics ---"
enable_boot_diagnostics "$RGNAME" "$VMNAME" || { echo "Warning: Failed to enable boot diagnostics for VM '$VMNAME'."; }
echo "Boot diagnostics enabled (if successful)."

echo "" # Blank line
echo "Script execution complete. VM '$VMNAME' is being deployed."