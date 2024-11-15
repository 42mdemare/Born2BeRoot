#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

while true; do
  ARCH=$(uname -m)
  DISTRIBUTION=$(cat /etc/redhat-release | awk '{print $1}')
  VERSION=$(cat /etc/redhat-release | awk '{print $4}')
  KERNEL=$(uname -r)
  CPU_PHYSICAL=$(lscpu | grep "Socket(s):" | awk '{print $2}')
  VCPU=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
  RAM_USAGE=$(free -m | awk 'NR==2{printf "%.0f/%.0fMB (%.2f%%)", $3, $2, $3*100/$2}')
  DISK_USAGE=$(df -BG --output=size,used,pcent / | awk 'NR==2 {printf "%s/%s (%s)\n", $2, $1, $3}')
  CPU_LOAD=$(top -b -n1 | grep "Cpu(s)" | awk '{printf "%.1f%%", $2+$4}')
  LAST_BOOT=$(who -b | awk '{print $3, $4}')
  LVM_STATUS=$(/usr/sbin/lvs --noheadings -o lv_active LVMGroup 2>/dev/null | head -n 1 | grep -q "active" && echo "yes" || echo "no")
  TCP_CONNECTIONS=$(ss -tn state established '( dport = :ssh or sport = :ssh )' | grep -c -v LISTEN)
  USER_LOG=$(users | wc -w)
  IP_MAC=$(ip -4 -o addr show | awk '!/^[0-9]*: ?lo/ {print $4 " ("$6")"}')
  SUDO_CMDS=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

  MESSAGE="
##################################################
#               SYSTEM MONITORING                #
##################################################
# Architecture    : $DISTRIBUTION $KERNEL $VERSION $ARCH
# [CPU] Physical  : $CPU_PHYSICAL
# [vCPU] Threads  : $VCPU
# [RAM] Usage     : $RAM_USAGE
# [DISK] Usage    : $DISK_USAGE
# [LOAD] CPU Load : $CPU_LOAD
# [BOOT] Last Boot: $LAST_BOOT
# [LVM] Active    : $LVM_STATUS
# [TCP] Connexions: $TCP_CONNECTIONS ESTABLISHED
# [USER] Logged In: $USER_LOG
# [NET] Network   : $IP_MAC
# [SUDO] Commands : $SUDO_CMDS executed
##################################################
"

  echo "$MESSAGE" | wall
  sleep 600
done
