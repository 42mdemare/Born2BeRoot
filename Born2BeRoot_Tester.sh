#!/bin/bash

DEF_COLOR='\033[0;39m'
BLACK='\033[0;30m'
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
GRAY='\033[0;90m'
WHITE='\033[0;97m'

printf "${BLUE}______                   _____ ______     ______           _          \n${DEF_COLOR}";
printf "${BLUE}| ___ \                 / __  \| ___ \    | ___ \         | |         \n${DEF_COLOR}";
printf "${BLUE}| |_/ / ___  _ __ _ __  \/ / /'| |_/ / ___| |_/ /___   ___| | ___   _ \n${DEF_COLOR}";
printf "${CYAN}| ___ \/ _ \| '__| '_ \   / /  | ___ \/ _ \    // _ \ / __| |/ / | | |\n${DEF_COLOR}";
printf "${CYAN}| |_/ / (_) | |  | | | |./ /___| |_/ /  __/ |\ \ (_) | (__|   <| |_| |\n${DEF_COLOR}";
printf "${CYAN}\____/ \___/|_|  |_| |_|\_____/\____/ \___\_| \_\___/ \___|_|\_\\__, |\n${DEF_COLOR}";
printf "${CYAN}                                                                 __/ | Tester \n${DEF_COLOR}";
printf "${CYAN}                                                                |___/  By Mdemare\n\n${DEF_COLOR}";

USER=$(whoami)

if [ $USER != "root" ]; then
  printf "${RED}Opps! You don't have permission. Make sure you run the command with sudo permission - (sudo bash test.sh)${DEF_COLOR}\n\n";
  exit;
fi

# Check if GUI mode is disabled
printf "${MAGENTA}1. GUI MODE DISABLE?${DEF_COLOR}\n";
RES=$(systemctl get-default)
if [[ $RES == "multi-user.target" ]]; then
  printf "${GREEN}[GOOD] ✔${GRAY} GUI mode disabled${DEF_COLOR}\n";
else
  printf "${RED}[FAILED] ✗${GRAY} GUI mode enabled${DEF_COLOR}\n";
fi

# Hostname check
echo
printf "${MAGENTA}2. Hostname${DEF_COLOR}\n";
RES=$(hostname)
EXPECTED_HOSTNAME="$(env | grep SUDO_USER | head -1 | cut -d '=' -f2)42"
if [ "$RES" == "$EXPECTED_HOSTNAME" ]; then
  printf "${GREEN}[GOOD] ✔${DEF_COLOR}\n";
else
  printf "${RED}[FAILED] ✗${DEF_COLOR}\n";
fi

# LVM and encrypted partitions
# Vérification des partitions
echo
printf "${MAGENTA}3. Disk partitions${DEF_COLOR}\n";

# Vérification des partitions obligatoires
RES=$(lsblk | grep lvm | wc -l)
if [ $RES -gt 1 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} LVM partitions detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No LVM partitions found${DEF_COLOR}\n"
fi

RES=$(lsblk | grep home | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Home partition detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No home partition found${DEF_COLOR}\n"
fi

RES=$(lsblk | grep swap | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Swap partition detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No swap partition found${DEF_COLOR}\n"
fi

RES=$(lsblk | grep root | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Root partition detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No root partition found${DEF_COLOR}\n"
fi

# Vérification des partitions bonus
echo
printf "${MAGENTA}3. Bonus Disk Partitions (Optional)${DEF_COLOR}\n";

RES=$(lsblk | grep var | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Var partition detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No var partition found${DEF_COLOR}\n"
fi

RES=$(lsblk | grep srv | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Srv partition detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No srv partition found${DEF_COLOR}\n"
fi

RES=$(lsblk | grep tmp | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Tmp partition detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No tmp partition found${DEF_COLOR}\n"
fi

RES=$(lsblk | grep var--log | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Var-log partition detected${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No var-log partition found${DEF_COLOR}\n"
fi

# Firewalld configuration
echo
printf "${MAGENTA}4. Firewalld (Firewall)${DEF_COLOR}\n";
systemctl is-active firewalld &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} Firewalld active${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} Firewalld inactive${DEF_COLOR}\n";
firewall-cmd --list-ports | grep -q "4242" && printf "${GREEN}[GOOD] ✔${GRAY} Port 4242 open${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} Port 4242 closed${DEF_COLOR}\n";

# Bonus: Web server and services
echo
printf "${MAGENTA}5. Bonus: Web server and services${DEF_COLOR}\n";
systemctl is-active lighttpd &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} Lighttpd active${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} Lighttpd inactive${DEF_COLOR}\n";
systemctl is-active mariadb &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} MariaDB active${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} MariaDB inactive${DEF_COLOR}\n";
firewall-cmd --list-ports | grep -q "80" && printf "${GREEN}[GOOD] ✔${GRAY} HTTP port 80 open${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} HTTP port 80 closed${DEF_COLOR}\n";

# PAM configuration for password policy
echo
printf "${MAGENTA}6. Password policy${DEF_COLOR}\n";

# minlen
RES=$(grep -o "minlen=10" /etc/security/pwquality.conf)
if [ "$RES" == "minlen=10" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} minlen${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} minlen${DEF_COLOR}\n"
fi

# ucredit
RES=$(grep -o "ucredit=-1" /etc/security/pwquality.conf)
if [ "$RES" == "ucredit=-1" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} uppercase (ucredit)${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} uppercase (ucredit)${DEF_COLOR}\n"
fi

# lcredit
RES=$(grep -o "lcredit=-1" /etc/security/pwquality.conf)
if [ "$RES" == "lcredit=-1" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} lowercase (lcredit)${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} lowercase (lcredit)${DEF_COLOR}\n"
fi

# dcredit
RES=$(grep -o "dcredit=-1" /etc/security/pwquality.conf)
if [ "$RES" == "dcredit=-1" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} digit (dcredit)${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} digit (dcredit)${DEF_COLOR}\n"
fi

# maxrepeat
RES=$(grep -o "maxrepeat=3" /etc/security/pwquality.conf)
if [ "$RES" == "maxrepeat=3" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} consecutive characters (maxrepeat)${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} consecutive characters (maxrepeat)${DEF_COLOR}\n"
fi

# difok
RES=$(grep -o "difok=7" /etc/security/pwquality.conf)
if [ "$RES" == "difok=7" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} different characters (difok)${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} different characters (difok)${DEF_COLOR}\n"
fi

# enforce_for_root
RES=$(grep -o "enforce_for_root" /etc/security/pwquality.conf)
if [ "$RES" == "enforce_for_root" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} enforce_for_root${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} enforce_for_root${DEF_COLOR}\n"
fi

# reject_username
RES=$(grep -o "reject_username" /etc/security/pwquality.conf)
if [ "$RES" == "reject_username" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} reject_username${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} reject_username${DEF_COLOR}\n"
fi

# PASS_MAX_DAYS
RES=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
if [ "$RES" == "30" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} PASS_MAX_DAYS = 30${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} PASS_MAX_DAYS${DEF_COLOR}\n"
fi

# PASS_MIN_DAYS
RES=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
if [ "$RES" == "2" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} PASS_MIN_DAYS = 2${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} PASS_MIN_DAYS${DEF_COLOR}\n"
fi

# PASS_WARN_AGE
RES=$(grep "^PASS_WARN_AGE" /etc/login.defs | awk '{print $2}')
if [ "$RES" == "7" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} PASS_WARN_AGE = 7${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} PASS_WARN_AGE${DEF_COLOR}\n"
fi

# Vérification du dossier /var/log/sudo
if [ -d "/var/log/sudo/" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} folder /var/log/sudo exists${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} folder /var/log/sudo does not exist${DEF_COLOR}\n"
fi

# SSH Configuration
echo
printf "${MAGENTA}7. SSH Configuration${DEF_COLOR}\n";
systemctl is-active sshd &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} SSH active${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} SSH inactive${DEF_COLOR}\n";
semanage port -l | grep -q "4242" && printf "${GREEN}[GOOD] ✔${GRAY} Port 4242 allowed in SELinux${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} Port 4242 not allowed in SELinux${DEF_COLOR}\n";

# Monitoring script cron job
echo
printf "${MAGENTA}8. Cronjob for monitoring script${DEF_COLOR}\n";
crontab -l | grep -q "monitoring.sh" && printf "${GREEN}[GOOD] ✔${GRAY} Monitoring script scheduled${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} Monitoring script missing in cron${DEF_COLOR}\n";

echo
printf "${CYAN}Mandatory and Bonus Tests Completed, your have Rockyed!${DEF_COLOR}\n\n";
