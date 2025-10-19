#!/bin/bash
# 說明：
# 建1個Windows VM 作 client加入domain


#Update based on your organizational requirements
Location=japaneast
ResourceGroupName=ADLab
NetworkSecurityGroup=NSG-DomainControllers
VNetName=ADLabVnet
SubnetName=ADlabVent-Sub1
SubnetAddress=10.10.10.0/24
IMAGE="MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest"
VMSize=Standard_D2ls_v5
AdminUsername=<input by your self>
AdminPassword=<input by your self> 
ClientVM=Win01
ClientIP=10.10.10.13


# Create client virtual machine.
az vm create \
    --resource-group "$ResourceGroupName" \
    --name "$ClientVM" \
    --size "$VMSize" \
    --image "$IMAGE" \
    --admin-username "$AdminUsername" \
    --admin-password "$AdminPassword" \
    --nsg "$NetworkSecurityGroup" \
    --private-ip-address "$ClientIP"


