#!/bin/bash

CONFIG_FILE="azure_configs.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found."
    echo "Please ensure you are in the correct directory or specify the correct path."
    exit 1
fi

echo "--- Available Azure Environments ---"
# Use jq to parse JSON and list options
# If jq is not installed, install it first: sudo apt-get install jq (Linux) or brew install jq (macOS)
jq -c '.[] | .name, .description' "$CONFIG_FILE" | sed 'N;s/\n/ - /' | nl

echo "--------------------------"
read -p "Enter the number of the environment to switch to (Press Enter to cancel): " env_number

if [[ -z "$env_number" ]]; then
    echo "Switch cancelled."
    exit 0
fi

# Validate if the input is a number
if ! [[ "$env_number" =~ ^[0-9]+$ ]]; then
    echo "Invalid input: Please enter a number."
    exit 1
fi

# Get the selected environment configuration
# jq's index starts from 0, so we subtract 1
selected_env=$(jq ".[$((env_number - 1))]" "$CONFIG_FILE")

if [ -z "$selected_env" ] || [ "$selected_env" == "null" ]; then
    echo "Invalid environment number: No corresponding environment found."
    exit 1
fi

TENANT_ID=$(echo "$selected_env" | jq -r '.tenantId')
SUBSCRIPTION_ID=$(echo "$selected_env" | jq -r '.subscriptionId')
ENV_NAME=$(echo "$selected_env" | jq -r '.name')

echo ""
echo "Switching to environment: $ENV_NAME"
echo "Tenant ID: $TENANT_ID"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo ""

# Execute az login; use --tenant if switching tenants
# Determine if a tenant relogin is needed based on the current account's tenantId
CURRENT_TENANT_ID=$(az account show --query "tenantId" -o tsv 2>/dev/null)

if [ "$CURRENT_TENANT_ID" != "$TENANT_ID" ]; then
    echo "Logging into new tenant ($TENANT_ID)..."
    az login --tenant "$TENANT_ID" --use-device-code --output none
    if [ $? -ne 0 ]; then
        echo "Failed to log in to tenant. Please check your credentials or network."
        exit 1
    fi
else
    echo "Already in target tenant ($TENANT_ID), skipping az login."
fi

# Set the subscription
echo "Setting subscription ($SUBSCRIPTION_ID)..."
az account set --subscription "$SUBSCRIPTION_ID" --output none
if [ $? -ne 0 ]; then
    echo "Failed to set subscription. Please verify the subscription ID or your account permissions."
    exit 1
fi

echo "Successfully switched to '$ENV_NAME' environment."
echo "Current subscription info:"
az account show --output table