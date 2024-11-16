MESSAGE="
####################################################################
##                                                                ##
##                      SYSTEM MONITORING REPORT                  ##
##                                                                ##
####################################################################
##                                                                ##
##   [SYSTEM]                                                     ##
##   Distribution               : $DISTRIBUTION                           ##
##   Kernel Version             : $KERNEL         ##
##   System Version             : $VERSION                                ##
##   Hardware Architecture      : $ARCH                   ##
##                                                                ##
##   [PROCESSOR]                                                  ##
##   Physical CPUs              : $CPU_PHYSICAL                               ##
##   Virtual CPUs (Threads)     : $VCPU                               ##
##   CPU Load                   : $CPU_LOAD                       ##
##                                                                ##
##   [MEMORY AND STORAGE]                                         ##
##   RAM Usage                  : $RAM_USAGE              ##
##   Disk Usage                 : $DISK_USAGE                     ##
##                                                                ##
##   [BOOT AND STATUS]                                            ##
##   Last Boot                  : $LAST_BOOT              ##
##   LVM Active                 : $LVM_STATUS                             ##
##                                                                ##
##   [NETWORK]                                                    ##
##   IPv4 Address               : $IP                     ##
##   MAC Address                : $MAC            ##
##                                                                ##
##   [SECURITY]                                                   ##
##   Sudo Commands Executed     : $SUDO_CMDS                              ##
##                                                                ##
##   [CONNECTIONS]                                                ##
##   Active TCP Connections     : $TCP_CONNECTIONS                               ##
##   Logged In Users            : $USER_LOG                               ##
##                                                                ##
####################################################################
"

# Broadcast the message to all connected terminals
echo "$MESSAGE" | wall 2>/dev/null
echo ""
