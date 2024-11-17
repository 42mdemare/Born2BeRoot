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

FAILED=0

printf "${BLUE}______                   _____ ______     ______           _          \n${DEF_COLOR}";
printf "${BLUE}| ___ \                 / __  \| ___ \    | ___ \         | |         \n${DEF_COLOR}";
printf "${BLUE}| |_/ / ___  _ __ _ __  \/ / /'| |_/ / ___| |_/ /___   ___| | ___   _ \n${DEF_COLOR}";
printf "${BLUE}| ___ \/ _ \| '__| '_ \   / /  | ___ \/ _ \    // _ \ / __| |/ / | | |\n${DEF_COLOR}";
printf "${BLUE}| |_/ / (_) | |  | | | |./ /___| |_/ /  __/ |\ \ (_) | (__|   <| |_| |\n${DEF_COLOR}";
printf "${BLUE}\____/ \___/|_|  |_| |_|\_____/\____/ \___\_| \_\___/ \___|_|\_\\__, |\n${DEF_COLOR}";
printf "${BLUE}                                                                 __/ | Tester \n${DEF_COLOR}";
printf "${BLUE}                                                                |___/  By Mdemare\n\n${DEF_COLOR}";

USER=$(whoami)

if [ $USER != "root" ]; then
  printf "${RED}Opps! You don't have permission. Make sure you run the command with sudo permission - (sudo bash test.sh)${DEF_COLOR}\n\n";
  exit;
fi

printf "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗\n${DEF_COLOR}"
printf "${BLUE}║                                Mandatory Tests                               ║\n${DEF_COLOR}"
printf "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝\n${DEF_COLOR}"

# Check if GUI mode is disabled
printf "${MAGENTA}1. GUI MODE DISABLE?${DEF_COLOR}\n";
RES=$(systemctl get-default)
if [[ $RES == "multi-user.target" ]]; then
  printf "${GREEN}[GOOD] ✔${GRAY} GUI mode disabled${DEF_COLOR}\n";
else
  printf "${RED}[FAILED] ✗${GRAY} GUI mode enabled${DEF_COLOR}\n";
  FAILED=$((FAILED + 1))
fi

# Hostname check
echo
printf "${MAGENTA}2. Hostname${DEF_COLOR}\n";
RES=$(hostname)
EXPECTED_HOSTNAME="$(env | grep SUDO_USER | head -1 | cut -d '=' -f2)42"
if [ "$RES" == "$EXPECTED_HOSTNAME" ]; then
  printf "${GREEN}[GOOD] ✔${DEF_COLOR} $RES\n";
else
  printf "${RED}[FAILED] ✗${DEF_COLOR} $RES\n";
  FAILED=$((FAILED + 1))
fi

# LVM and encrypted partitions
echo
printf "${MAGENTA}3. Disk partitions${DEF_COLOR}\n";

# Vérification des partitions obligatoires
RES=$(lsblk | grep lvm | wc -l)
if [ $RES -gt 1 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} LVM partitions detected${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No LVM partitions found${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

RES=$(lsblk | grep home | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Home partition detected${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No home partition found${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

RES=$(lsblk | grep swap | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Swap partition detected${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No swap partition found${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

RES=$(lsblk | grep root | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Root partition detected${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No root partition found${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

# Firewalld configuration
echo
printf "${MAGENTA}4. Firewalld (Firewall)${DEF_COLOR}\n";
systemctl is-active firewalld &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} Firewalld active${DEF_COLOR} $RES\n" || printf "${RED}[FAILED] ✗${GRAY} Firewalld inactive${DEF_COLOR} $RES\n"FAILED=$((FAILED + 1));
firewall-cmd --list-ports | grep -q "4242" && printf "${GREEN}[GOOD] ✔${GRAY} Port 4242 open${DEF_COLOR} $RES\n" || printf "${RED}[FAILED] ✗${GRAY} Port 4242 closed${DEF_COLOR} $RES\n"FAILED=$((FAILED + 1));

# PAM configuration for password policy
echo
printf "${MAGENTA}5. Password policy${DEF_COLOR}\n";

# Fonction générique pour tester un paramètre dans un fichier spécifique
test_param_in_file() {
  local file="$1"
  local param="$2"
  local expected_value="$3"
  local description="$4"
  local found=0

  if [ -n "$expected_value" ]; then
    # Tester avec une valeur spécifique
    RES=$(grep -Po "^\s*$param\s*=\s*$expected_value" "$file" | tr -d '[:space:]')
    [ "$RES" == "$param=$expected_value" ] && found=1
  else
    # Tester sans valeur
    RES=$(grep -Po "^\s*$param\b" "$file")
    [ "$RES" == "$param" ] && found=1
  fi

  # Résultat final
  if [ $found -eq 1 ]; then
    printf "${GREEN}[GOOD] ✔${GRAY} $description${DEF_COLOR} $RES\n"
  else
    printf "${RED}[FAILED] ✗${GRAY} $description${DEF_COLOR} $RES\n"
    FAILED=$((FAILED + 1))
  fi
}

# Fonction pour tester un paramètre dans plusieurs fichiers
test_param_in_files() {
  local param="$1"
  local expected_value="$2"
  local description="$3"
  local found=0

  # Liste des fichiers à vérifier
  local files=(
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
  )

  for file in "${files[@]}"; do
    if [ -n "$expected_value" ]; then
      # Tester avec une valeur spécifique
      RES=$(grep -Po "^\s*password\s+requisite\s+pam_pwquality\.so.*\b$param\s*=\s*$expected_value\b" "$file")
    else
      # Tester sans valeur
      RES=$(grep -Po "^\s*password\s+requisite\s+pam_pwquality\.so.*\b$param\b" "$file")
    fi

    if [ -n "$RES" ]; then
      found=1
      break
    fi
  done

  # Résultat final
  if [ $found -eq 1 ]; then
    printf "${GREEN}[GOOD] ✔${GRAY} $description${DEF_COLOR} $RES\n"
  else
    printf "${RED}[FAILED] ✗${GRAY} $description${DEF_COLOR} $RES\n"
    FAILED=$((FAILED + 1))
  fi
}

# Tester les paramètres requis dans /etc/security/pwquality.conf
test_param_in_file "/etc/security/pwquality.conf" "minlen" "10" "Minimum password length (minlen)"
test_param_in_file "/etc/security/pwquality.conf" "ucredit" "-1" "Uppercase character requirement (ucredit)"
test_param_in_file "/etc/security/pwquality.conf" "lcredit" "-1" "Lowercase character requirement (lcredit)"
test_param_in_file "/etc/security/pwquality.conf" "dcredit" "-1" "Digit character requirement (dcredit)"
test_param_in_file "/etc/security/pwquality.conf" "maxrepeat" "3" "Maximum repeated characters (maxrepeat)"
test_param_in_file "/etc/security/pwquality.conf" "difok" "7" "Minimum different characters (difok)"
test_param_in_file "/etc/security/pwquality.conf" "enforce_for_root" "" "Enforce password rules for root"

# Vérification de reject_username ou usercheck dans pwquality.conf
RES=$(grep -Po "^\s*(reject_username|usercheck\s*=\s*1)" /etc/security/pwquality.conf | tr -d '[:space:]')
if [ "$RES" == "reject_username" ] || [ "$RES" == "usercheck=1" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Username restriction active (reject_username or usercheck=1)${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} Username restriction inactive${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

# Tester les paramètres requis dans PAM (system-auth et password-auth)
test_param_in_files "minlen" "10" "Minimum password length (minlen) in PAM"
test_param_in_files "ucredit" "-1" "Uppercase character requirement (ucredit) in PAM"
test_param_in_files "lcredit" "-1" "Lowercase character requirement (lcredit) in PAM"
test_param_in_files "dcredit" "-1" "Digit character requirement (dcredit) in PAM"
test_param_in_files "difok" "7" "Minimum different characters (difok) in PAM"
test_param_in_files "reject_username" "" "Reject username as password in PAM"
test_param_in_files "enforce_for_root" "" "Enforce password rules for root in PAM"

# PASS_MAX_DAYS
RES=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
if [ "$RES" == "30" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} PASS_MAX_DAYS = 30${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} PASS_MAX_DAYS${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

# PASS_MIN_DAYS
RES=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
if [ "$RES" == "2" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} PASS_MIN_DAYS = 2${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} PASS_MIN_DAYS${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

# PASS_WARN_AGE
RES=$(grep "^PASS_WARN_AGE" /etc/login.defs | awk '{print $2}')
if [ "$RES" == "7" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} PASS_WARN_AGE = 7${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} PASS_WARN_AGE${DEF_COLOR} $RES\n"
  FAILED=$((FAILED + 1))
fi

# Vérification du dossier /var/log/sudo
if [ -d "/var/log/sudo/" ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} folder /var/log/sudo exists${DEF_COLOR}\n"
else
  printf "${RED}[FAILED] ✗${GRAY} folder /var/log/sudo does not exist${DEF_COLOR}\n"
  FAILED=$((FAILED + 1))
fi

# SSH Configuration
echo
printf "${MAGENTA}6. SSH Configuration${DEF_COLOR}\n";
systemctl is-active sshd &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} SSH active${DEF_COLOR} $RES\n" || printf "${RED}[FAILED] ✗${GRAY} SSH inactive${DEF_COLOR} $RES\n" FAILED=$((FAILED + 1));
semanage port -l | grep -q "4242" && printf "${GREEN}[GOOD] ✔${GRAY} Port 4242 allowed in SELinux${DEF_COLOR} $RES\n" || printf "${RED}[FAILED] ✗${GRAY} Port 4242 not allowed in SELinux${DEF_COLOR} $RES\n" FAILED=$((FAILED + 1));

# Monitoring script cron job
echo
printf "${MAGENTA}7. Cronjob for monitoring script${DEF_COLOR}\n";
crontab -l | grep -q "monitoring.sh" && printf "${GREEN}[GOOD] ✔${GRAY} Monitoring script scheduled${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} Monitoring script missing in cron${DEF_COLOR}\n" FAILED=$((FAILED + 1));

printf "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗\n${DEF_COLOR}"
printf "${BLUE}║                                   Bonus Tests                                ║\n${DEF_COLOR}"
printf "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝\n${DEF_COLOR}"

# Vérification des partitions bonus
echo
printf "${MAGENTA}1. Bonus Disk Partitions (Optional)${DEF_COLOR}\n";

RES=$(lsblk | grep var | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Var partition detected${DEF_COLOR} $RES \n"
else
  printf "${RED}[FAILED] ✗${GRAY} No var partition found${DEF_COLOR} $RES\n"
fi

RES=$(lsblk | grep srv | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Srv partition detected${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No srv partition found${DEF_COLOR} $RES\n"
fi

RES=$(lsblk | grep tmp | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Tmp partition detected${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No tmp partition found${DEF_COLOR} $RES\n"
fi

RES=$(lsblk | grep var--log | wc -l)
if [ $RES -gt 0 ]; then
  printf "${GREEN}[GOOD] ✔${GRAY} Var-log partition detected${DEF_COLOR} $RES\n"
else
  printf "${RED}[FAILED] ✗${GRAY} No var-log partition found${DEF_COLOR} $RES\n"
fi

# Bonus: Web server and services
echo
printf "${MAGENTA}2. Bonus: Web server and services${DEF_COLOR}\n";
systemctl is-active lighttpd &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} Lighttpd active${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} Lighttpd inactive${DEF_COLOR}\n";
systemctl is-active mariadb &>/dev/null && printf "${GREEN}[GOOD] ✔${GRAY} MariaDB active${DEF_COLOR}\n" || printf "${RED}[FAILED] ✗${GRAY} MariaDB inactive${DEF_COLOR}\n";

# Last message according to the results
echo
if [ $FAILED -eq 0 ]; then
printf "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗\n${DEF_COLOR}"
printf "${GREEN}║   🎉🥳  Mandatory and Bonus Tests Completed, your have Rockyed it! 🥳🎉    ║\n${DEF_COLOR}"
printf "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝\n${DEF_COLOR}"
else
printf "${RED}╔══════════════════════════════════════════════════════════════════════════════╗\n${DEF_COLOR}"
printf "${RED}║ 😢💔 Some tests failed. 😞It's sad😢Please review the issues above. 💔😢  ║\n${DEF_COLOR}"
printf "${RED}╚══════════════════════════════════════════════════════════════════════════════╝\n${DEF_COLOR}"
fi
