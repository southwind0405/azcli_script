<#
.SYNOPSIS
    【僅限測試環境】自動化安裝與設定 Active Directory Domain Services。
.DESCRIPTION
    此腳本會安裝 AD DS 角色，然後使用在腳本中直接定義的純文字密碼，
    全自動地將伺服器提升為新的樹系中的第一台網域控制站。
.WARNING
    此腳本包含純文字密碼，存在嚴重安全風險。切勿在生產環境中使用。
#>

# --- Script Configuration ---

# 域名設定
$domainName = "southwind.local" 
$netbiosName = "SOUTHWIND"

# ===================================================================
# 警告：將純文字密碼儲存在腳本中存在嚴重的安全風險。
# 這僅是為了在完全隔離的測試環境中實現全自動化。
$plainTextPassword = "YourComplexPassword!123" # <--- 請將這裡的密碼替換成您自己的複雜密碼
# ===================================================================

# 將純文字密碼轉換為 Install-ADDSForest 所需的 SecureString 格式
$securePassword = ConvertTo-SecureString -String $plainTextPassword -AsPlainText -Force

# --- 1. 安裝 Active Directory Domain Services 角色 ---

Write-Host "Installing Active Directory Domain Services role..." -ForegroundColor Green
$installResult = Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# --- 2. 檢查安裝結果 ---

# 檢查安裝是否成功
if (-not $installResult.Success) {
    Write-Error "Failed to install AD-Domain-Services role. Please check the logs. Script is terminating."
    exit
}

# 檢查是否需要重新啟動
if ($installResult.RestartNeeded) {
    Write-Warning "A restart is required to complete the role installation. Please restart the server and run the subsequent configuration steps again."
    # 如果希望腳本自動重啟，可以取消下面一行的註解
    # Restart-Computer -Force
    exit
}

Write-Host "Role installed successfully." -ForegroundColor Green

# --- 3. 部署新的 Active Directory 樹系 ---

try {
    # 匯入部署模組
    Write-Host "Importing ADDSDeployment module..." -ForegroundColor Green
    Import-Module ADDSDeployment
    
    Write-Host "Configuring and deploying the new Active Directory forest..." -ForegroundColor Green
    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "Win2016" ` # 或根據您的環境設定為 "Win2019" / "Win2022"
        -DomainName $domainName `
        -DomainNetbiosName $netbiosName `
        -ForestMode "Win2016" `  # 或根據您的環境設定為 "Win2019" / "Win2022"
        -InstallDns:$true `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$false ` # 完成後會自動重啟
        -SysvolPath "C:\Windows\SYSVOL" `
        -SafeModeAdministratorPassword $securePassword ` # 使用從純文字轉換來的安全密碼
        -Force:$true # 強制執行，不會有額外的確認提示
        
    Write-Host "Active Directory forest deployment command has been submitted successfully. The server will now restart to complete the configuration." -ForegroundColor Green

}
catch {
    # 如果部署過程中發生任何錯誤，將會被捕捉到並顯示
    Write-Error "An error occurred during Active Directory forest deployment:"
    Write-Error $_.Exception.Message
    exit
}
