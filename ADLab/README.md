Microsoft AD lab


# 使用ARM teamplate 自動部署
## 檔案
- azuredeploy.json : 主檔
- azuredeploy_parameters.json ： 參數檔
- CSE 腳本 url ： https://raw.githubusercontent.com/southwind0405/azcli_script/main/ADLab/adds_dep.ps1
## 執行方式
az group create --name "<輸入resource group name>" --location "japaneast"
az deployment group create --resource-group "<輸入resource group name>" --template-file "azuredeploy.json" --parameters "azuredeploy_parameters.json"
---
### 設定DNS環境
- 要在建立的VM的NIC上設定custom dns: ["vm的private IP","127.0.0.1]
- 要在建立的subnet上設定custom dns: "vm的private IP"

