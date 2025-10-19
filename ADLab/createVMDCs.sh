#!/bin/bash
# 說明：
# 建2個Windows VM 作 domain controller 的lab環境 
# 在指定的Location 建立,
#   resource group
#   NSG
#     NSG rule allow 指定的 ip來源 連線目的端的 3389 port 
#   vnet VNetAddress 10.10.0.0/16
#     subnet 10.10.10.0/24 attache 剛剛建的NSG
#   VM1 as DC1
#   VM2 as DC2

#Update based on your organizational requirements
Location=japaneast
ResourceGroupName=ADLab
NetworkSecurityGroup=NSG-DomainControllers
VNetName=ADLabVnet
VNetAddress=10.10.0.0/16
SubnetName=ADlabVent-Sub1
SubnetAddress=10.10.10.0/24
IMAGE="MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest"
VMSize=Standard_D2ls_v5
#DataDiskSize=20
AdminUsername="<輸入您的user account>"
AdminPassword="<輸入你的密碼>"
DomainController1=AZDC01
DC1IP=10.10.10.11
#DomainController2=AZDC02
#DC2IP=10.10.10.12

# Create a resource group.
az group create --name "$ResourceGroupName" \
                --location "$Location"

# Create a network security group
az network nsg create --name "$NetworkSecurityGroup" \
                      --resource-group "$ResourceGroupName" \
                      --location "$Location"

# Create a network security group rule for port 3389.
az network nsg rule create --name "PermitRDP" \
                           --nsg-name "$NetworkSecurityGroup" \
                           --priority 1000 \
                           --resource-group "$ResourceGroupName" \
                           --access Allow \
                           --source-address-prefixes "4.192.0.0/12" "167.220.0.0/16" "114.32.184.200" \
                           --source-port-ranges "*" \
                           --direction Inbound \
                           --destination-port-ranges 3389

# Create a virtual network.
az network vnet create --name "$VNetName" \
                       --resource-group "$ResourceGroupName" \
                       --address-prefixes "$VNetAddress" \
                       --location "$Location" \

# Create a subnet
az network vnet subnet create --address-prefix "$SubnetAddress" \
                              --name "$SubnetName" \
                              --resource-group "$ResourceGroupName" \
                              --vnet-name "$VNetName" \
                              --network-security-group "$NetworkSecurityGroup"

# Create two virtual machines.
az vm create \
    --resource-group "$ResourceGroupName" \
    --name "$DomainController1" \
    --size "$VMSize" \
    --image "$IMAGE" \
    --admin-username "$AdminUsername" \
    --admin-password "$AdminPassword" \
    --vnet-name "$VNetName" \
    --subnet "$SubnetName" \
    --nsg "$NetworkSecurityGroup" \
    --private-ip-address "$DC1IP"
    #--no-wait

# az vm create \
    # --resource-group "$ResourceGroupName" \
    # --name "$DomainController2" \
    # --size "$VMSize" \
    # --image "$IMAGE" \
    # --admin-username "$AdminUsername" \
    # --admin-password "$AdminPassword" \
    # --vnet-name "$VNetName" \
    # --subnet "$SubnetName" \
    # --nsg "$NetworkSecurityGroup" \
    # --private-ip-address "$DC2IP"
