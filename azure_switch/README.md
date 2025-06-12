-----

# Azure CLI Environment Switcher

This repository provides a simple yet effective way to manage multiple Azure environments (subscriptions across different tenants) using Azure CLI. It includes a configuration file to define your environments and a Bash script to easily switch between them.

-----

## Why Use This?

  * **Streamlined Workflow:** Quickly switch between your development, testing, and production Azure environments.
  * **Multi-Tenant Support:** Seamlessly handles subscriptions residing in different Azure Active Directory (Azure AD) tenants.
  * **Centralized Configuration:** Keep all your environment details in a single, easy-to-manage JSON file.
  * **Browser Control:** Choose which browser to use for `az login` authentication (via the device code flow), perfect if you have specific browser preferences for different accounts.
  * **Automation Friendly:** Integrate into your daily development tasks or CI/CD pipelines.

-----

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

  * **Azure CLI:** Follow the [official Azure CLI installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) for your operating system.
  * **`jq` (JSON processor):** This tool is used by the script to parse the JSON configuration file.
      * **Linux:** `sudo apt-get install jq`
      * **macOS:** `brew install jq`
      * **Windows (WSL):** `sudo apt-get install jq`
      * **Windows (Git Bash/PowerShell):** You might need to [download the `jq` executable for Windows](https://www.google.com/search?q=%5Bhttps://stedolan.github.io/jq/download/%5D\(https://stedolan.github.io/jq/download/\)) and add it to your system's PATH.

-----

### 1\. Configuration File (`azure_configs.json`)

Create a file named `azure_configs.json` in the same directory as your script. This file will store the details for each of your Azure environments.

```json
[
  {
    "name": "Dev Environment - Tenant A",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "subscriptionId": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "description": "Development environment for project X, in Tenant A."
  },
  {
    "name": "Prod Environment - Tenant B",
    "tenantId": "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz",
    "subscriptionId": "wwwwwwww-wwww-wwww-wwww-wwwwwwwwwwww",
    "description": "Production environment for project Y, in Tenant B."
  },
  {
    "name": "My Personal Sandbox",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "subscriptionId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    "description": "My personal playground, also in Tenant A."
  }
]
```

**Replace the placeholder values (`xxxxxxxx-...`, `yyyyyyyy-...`, etc.) with your actual Azure AD Tenant IDs and Azure Subscription IDs.** You can find these in the Azure Portal.

-----

### 2\. Environment Switcher Script (`switch_azure_env.sh`)

-----

## How to Use

1.  **Grant Execute Permissions:**
    ```bash
    chmod +x switch_azure_env.sh
    ```
2.  **Run the Script:**
    ```bash
    ./switch_azure_env.sh
    ```
3.  **Select Your Environment:**
    The script will display a numbered list of your configured Azure environments. Enter the number corresponding to the environment you wish to use.
4.  **Complete Login (if prompted):**
    If the script needs to perform an `az login` (e.g., you're switching to a new tenant or your token has expired), it will use the `--use-device-code` flow. This means you'll see a message in your terminal like:
    ```
    To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code XXXXXXXX to authenticate.
    ```
    **Manually open your preferred web browser (e.g., Edge for Tenant A, Chrome for Tenant B)**, navigate to the provided URL, and enter the displayed code. Once authenticated in the browser, the script will continue.

-----

## Security Considerations

  * This script does **not** store your Azure credentials directly. `az login` handles the authentication process securely.
  * By using `--use-device-code`, you have explicit control over which browser you use for the authentication flow, enhancing your security posture for different accounts.

-----

## Contribution

Feel free to fork this repository, open issues, or submit pull requests if you have improvements or suggestions\!
