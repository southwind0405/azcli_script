# Azure azcli scripts

Developers use azcli to manipulate azure scripts, e.g. create vm, deallocate all VMs, .... etc.


# Azure CLI VM Deployment Script

This project provides a modular and secure set of Bash scripts to automate the deployment of Virtual Machines (VMs) in Microsoft Azure using Azure CLI.

## 📁 Project Structure

| File          | Description |
|---------------|-------------|
| `createVM.sh` | Main script with interactive input and `getopts` support. |
| `functions.sh`| Reusable functions for resource creation and VM deployment. |
| `images.sh`   | Common VM image definitions categorized by OS type. |
| `.env`        | Stores sensitive credentials. **Do not commit this file.** |

## ⚙️ Prerequisites

- Azure CLI installed: Install Guide
- Logged in to Azure: `az login`
- Proper permissions to create resources

## 🚀 Usage

### Option 1: Interactive Mode
```bash
./script.sh
```
###  Option 2: Command-Line Mode
```bash
./script.sh -n myvm -g mygroup -l japaneast -i $UBUNTU_22 -N "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/networkSecurityGroups/xxx"
```
