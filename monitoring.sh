#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ARCH=$(uname -m)
DISTRIBUTION=$(awk '{print $1}' /etc/redhat-release)
VERSION=$(awk '{print $4}' /etc/redhat-release)
KERNEL=$(uname -r)
CPU_PHYSICAL=$(lscpu | awk '/Socket\(s\):/ {print $2}')
VCPU=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
RAM_USAGE=$(free -m | awk '/Mem:/ {printf "%.0f/%.0fMB (%.2f%%)", $3, $2, $3*100/$2}')
DISK_USAGE=$(df -BG --output=size,used,pcent / | awk 'NR==2 {printf "%s/%s (%s)\n", $2, $1, $3}')
CPU_LOAD=$(top -b -n1 | awk '/Cpu\(s\):/ {printf "%.1f%%", $2 + $4}')
LAST_BOOT=$(who -b | awk '{print $3, $4}')
LVM_STATUS=$(lsblk | grep -q "lvm" && echo "yes" || echo "no")
TCP_CONNECTIONS=$(ss -tn state established | grep -c ESTAB)
USER_LOG=$(who | wc -l)
IP=$(hostname -I | awk '{print $1}')
MAC=$(ip link show | awk '/ether/ {print $2}')
SUDO_CMDS=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

MESSAGE="
################################################################
#                    SYSTEM MONITORING REPORT                  #
################################################################
# Architecture           : $DISTRIBUTION $KERNEL $VERSION $ARCH
# [CPU] Physical         : $CPU_PHYSICAL
# [vCPU] Threads         : $VCPU
# [RAM] Usage            : $RAM_USAGE
# [Disk] Usage           : $DISK_USAGE
# [LOAD] CPU Load        : $CPU_LOAD
# [BOOT] Last Boot       : $LAST_BOOT
# [LVM] Use              : $LVM_STATUS
# [TCP] Connections      : $TCP_CONNECTIONS ESTABLISHED
# [USER] Logged In       : $USER_LOG
# [Network] IPv4         : $IP
# [Network] MAC          : $MAC
# Sudo Commands          : $SUDO_CMDS cmds executed
################################################################
"

echo "$MESSAGE" | wall 2>/dev/null
echo ""
