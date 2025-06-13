# Linux - UBUNTU
UBUNTU_16="Canonical:UbuntuServer:16.04-LTS:latest"
UBUNTU_16_g2="Canonical:UbuntuServer:16_04-lts-gen2:latest"
UBUNTU_18="Canonical:UbuntuServer:18.04-LTS:latest"
UBUNTU_18_g2="Canonical:UbuntuServer:18_04-lts-gen2:latest"
UBUNTU_20="Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest"
UBUNTU_20_g2="Canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:latest"
UBUNTU_22="Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
UBUNTU_22_g2="Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
UBUNTU_24="Canonical:ubuntu-24_04-lts-daily:server-gen1:latest"
UBUNTU_24_g2="Canonical:ubuntu-24_04-lts-daily:server:latest"

# Linux - DEBIAN
DEBIAN_10="Debian:debian-10:10:latest"
DEBIAN_10_g2="Debian:debian-10:10-gen2:latest"
DEBIAN_11="Debian:debian-11:11:latest"
DEBIAN_11_g2="Debian:debian-11:11-gen2:latest"
DEBIAN_12="Debian:debian-12:12:latest"
DEBIAN_12_g2="Debian:debian-12:12-gen2:latest"

# Linux - RedHat
RHEL_79="RedHat:RHEL:7_9:latest"
RHEL_79_g2="RedHat:RHEL:79-gen2:latest"
RHEL_7_LVM="RedHat:RHEL:7-LVM:latest"
RHEL_7_LVM_g2="RedHat:RHEL:7lvm-gen2:latest"
RHEL_8="RedHat:RHEL:8:latest"
RHEL_8_g2="RedHat:RHEL:8-gen2:latest"
RHEL_8_LVM="RedHat:RHEL:8-LVM:latest"
RHEL_8_LVM_g2="RedHat:RHEL:8-lvm-gen2:latest"
RHEL_810="RedHat:RHEL:8_10:latest"
RHEL_810_g2="RedHat:RHEL:810-gen2:latest"
RHEL_9_LVM="RedHat:RHEL:9-lvm:latest"
RHEL_9_LVM_g2="RedHat:RHEL:9-lvm-gen2:latest"
RHEL_96="RedHat:RHEL:9_6:latest"
RHEL_96_g2="RedHat:RHEL:96-gen2:latest"
RHEL_10_LVM="RedHat:RHEL:10-lvm:latest"
RHEL_10_LVM_g2="RedHat:RHEL:10-lvm-gen2:latest"
RHEL_100="RedHat:RHEL:10_0:latest"
RHEL_100_g2="RedHat:RHEL:100-gen2:latest"

# Linux - CentOS
CENTOS_79="OpenLogic:CentOS:7_9:latest"
CENTOS_79_g2="OpenLogic:CentOS:7_9-gen2:latest"
CENTOS_7_LVM="OpenLogic:CentOS-LVM:7-LVM:latest"
CENTOS_7_LVM_g2="OpenLogic:CentOS-LVM:7-lvm-gen2:latest"
CENTOS_85="OpenLogic:CentOS:8_5:latest"
CENTOS_85_g2="OpenLogic:CentOS:8_5-gen2:latest"
CENTOS_8_LVM="OpenLogic:CentOS-LVM:8-lvm:latest"
CENTOS_8_LVM_g2="OpenLogic:CentOS-LVM:8-lvm-gen2:latest"

# Linux - ORACLE
# az vm image list --all -p Oracle --query "[].{Offer:offer, Sku:sku}" -o tsv | sort -u
ORACLE_79="Oracle:Oracle-Linux:ol79:latest"
ORACLE_79_g2="Oracle:Oracle-Linux:ol79-gen2:latest"
ORACLE_89_LVM="Oracle:Oracle-Linux:ol89-lvm:latest"
ORACLE_89_LVM_g2="Oracle:Oracle-Linux:ol89-lvm-gen2:latest"
ORACLE_9_LVM="Oracle:Oracle-Linux:ol9-lvm:latest"
ORACLE_9_LVM_g2="Oracle:Oracle-Linux:ol9-lvm-gen2:latest"
ORACLE_95_LVM="Oracle:Oracle-Linux:ol95-lvm:latest"
ORACLE_95_LVM_g2="Oracle:Oracle-Linux:ol95-lvm-gen2:latest"

# Windows
# az vm image list --all -p MicrosoftWindowsServer -f WindowsServer -l japaneast -s 2025-Datacenter --query "[].urn" -o tsv
WIN_2016="MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest"
WIN_2016_g2="MicrosoftWindowsServer:WindowsServer:2016-datacenter-gensecond:latest"
WIN_2019="MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"
WIN_2019_g2="MicrosoftWindowsServer:WindowsServer:2019-datacenter-gensecond:latest"
WIN_2022="MicrosoftWindowsServer:WindowsServer:2022-datacenter:latest"
WIN_2022_g2="MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest"
WIN_2022_azure="MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest"
WIN_2022_azure_hotpatch="icrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition-hotpatch:latest"
WIN_2025="MicrosoftWindowsServer:WindowsServer:2025-datacenter:latest"
WIN_2025_g2="MicrosoftWindowsServer:WindowsServer:2025-datacenter-g2:latest"
WIN_2025_azure="MicrosoftWindowsServer:WindowsServer:2025-datacenter-azure-edition:latest"
WIN_2025_azure_hotpatch="icrosoftWindowsServer:WindowsServer:2025-datacenter-azure-edition-hotpatch:latest"




