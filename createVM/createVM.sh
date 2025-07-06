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
    echo "${1:-}" | tr -d '\r'
}

# Function: Confirm or switch Azure subscription
confirm_subscription() {
    local current_subscription
    current_subscription_raw=$(az account show --query id -o tsv) || { echo "Error: Could not get current Azure subscription. Please log in."; exit 1; }
    current_subscription=$(strip_carriage_return "$current_subscription_raw")
    
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
if [[ -z "${USERNAME:-}" || -z "${PASSWORD:-}" ]]; then
    echo "Error: USERNAME and PASSWORD must be set in the .env file."
    exit 1
fi

# --- Main Script Logic ---

# Parse command-line arguments
while getopts ":n:g:l:v:s:i:N:z:S:" opt; do
    case $opt in
        n) VMNAME=$OPTARG ;;
        g) RGNAME=$OPTARG ;;
        l) LOCATION=$OPTARG ;;
        v) VNETNAME=$OPTARG ;;
        s) SUBNETNAME=$OPTARG ;;
        i) OSIMAGE=$OPTARG ;;
        N) NSGNAME=$OPTARG ;;
        z) VMSIZE=$OPTARG ;;
        S) SUBSCRIPTION=$OPTARG ;;
        *) echo "Invalid option: -$OPTARG" ; exit 1 ;;
    esac
done

# Set subscription if provided, otherwise confirm
if [[ -n "${SUBSCRIPTION:-}" ]]; then
    az account set --subscription "$SUBSCRIPTION" || { echo "Error: Failed to set subscription to $SUBSCRIPTION."; exit 1; }
    echo "Subscription set to $SUBSCRIPTION."
else
    confirm_subscription
fi

echo "" # Add a blank line for better readability

# Only ask for RG name if it wasn't provided via the -g flag
if [[ -z "${RGNAME:-}" ]]; then
    read -p "Enter Resource Group name (default: ${DEFAULT_RGNAME}): " user_rgname
    RGNAME=${user_rgname:-$DEFAULT_RGNAME}
fi

# Only ask for location if it wasn't provided via the -l flag
if [[ -z "${LOCATION:-}" ]]; then
    read -p "Enter location (default: ${DEFAULT_LOCATION}): " user_location
    LOCATION=${user_location:-$DEFAULT_LOCATION}
fi

# Only ask for VM name if it wasn't provided via the -n flag
if [[ -z "${VMNAME:-}" ]]; then
    read -p "Enter VM name: " VMNAME
    [[ -z "$VMNAME" ]] && { echo "Error: VM name cannot be empty."; exit 1; }
fi

# Only ask for VM size if it wasn't provided via the -z flag
if [[ -z "${VMSIZE:-}" ]]; then
    read -p "Enter VM size (default: ${DEFAULT_VM_SIZE}): " user_vmsize
    VMSIZE=${user_vmsize:-$DEFAULT_VM_SIZE}
fi

# Set defaults for VNet and Subnet based on RG name
VNETNAME=${VNETNAME:-"${RGNAME}Vnet"}
SUBNETNAME=${SUBNETNAME:-"${RGNAME}Subnet"}

echo "--- Using Configuration ---"
echo "Resource Group: $RGNAME"
echo "Location:       $LOCATION"
echo "VM Name:        $VMNAME"
echo "VM Size:        $VMSIZE"
echo "VNet Name:      $VNETNAME"
echo "Subnet Name:    $SUBNETNAME"
echo "---------------------------"

# --- Ensure Azure Resources Exist ---
ensure_resource_group "$RGNAME" "$LOCATION"
ensure_vnet "$RGNAME" "$VNETNAME" "$SUBNETNAME" "$LOCATION"

# --- Determine NSG to use ---
if [[ -n "${NSGNAME:-}" ]]; then
    # Use specified NSG
    NSG_TO_USE=$(strip_carriage_return "$NSGNAME")
    echo "Using specified NSG: $NSG_TO_USE"
elif [[ "$RGNAME" == "$DEFAULT_RGNAME" ]]; then
    # Use default NSG for default RG
    NSG_TO_USE=$(strip_carriage_return "$DEFAULT_NSG")
    echo "Using default NSG for the lab: $NSG_TO_USE"
else
    # Create a new NSG for other resource groups
    local_nsg_name="${RGNAME}-nsg"
    echo "NSG not provided. Checking for existing NSG '$local_nsg_name' or creating a new one..."
    if ! az network nsg show --resource-group "$RGNAME" --name "$local_nsg_name" &>/dev/null; then
        az network nsg create --resource-group "$RGNAME" --name "$local_nsg_name" --location "$LOCATION" --output none || { echo "Error: Failed to create NSG '$local_nsg_name'."; exit 1; }
        echo "New NSG '$local_nsg_name' created."
    else
        echo "NSG '$local_nsg_name' already exists."
    fi
    new_nsg_id_raw=$(az network nsg show --resource-group "$RGNAME" --name "$local_nsg_name" --query id -o tsv)
    NSG_TO_USE=$(strip_carriage_return "$new_nsg_id_raw")
fi

# --- OS Image Selection ---
if [[ -z "${OSIMAGE:-}" ]]; then
    select_os_image # Call the new function to handle OS image selection
fi
echo "Selected OS Image: $OSIMAGE"

# --- VM Creation ---
echo ""
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
    "$NSG_TO_USE" \
    "$VMSIZE"
echo "Virtual Machine '$VMNAME' creation process initiated."

# --- Enable Boot Diagnostics ---
echo ""
echo "--- Enabling Boot Diagnostics ---"
enable_boot_diagnostics "$RGNAME" "$VMNAME"
echo "Boot diagnostics enabled."

echo ""
echo "Script execution complete. VM '$VMNAME' is being deployed."