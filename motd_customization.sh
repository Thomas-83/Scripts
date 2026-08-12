#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# CONFIGURATION
###############################################################################

MOTD_DIR="/etc/update-motd.d"
COLORS_FILE="${MOTD_DIR}/colors"

###############################################################################
# VERIFICATION ROOT
###############################################################################

if [[ "${EUID}" -ne 0 ]]; then
    printf '\n'
    printf 'ERREUR : ce script doit être exécuté avec les privilèges root.\n'
    printf '\n'
    printf 'Utilisation :\n'
    printf '  sudo %s\n' "$0"
    printf '\n'
    exit 1
fi

###############################################################################
# CREATION DU REPERTOIRE
###############################################################################

mkdir -p "${MOTD_DIR}"

###############################################################################
# DEFINITION DES COULEURS
###############################################################################

cat > "${COLORS_FILE}" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

NONE='\033[0m'

WHITE='\033[1;37m'
GREEN='\033[1;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'

LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
EOF

chmod 0755 "${COLORS_FILE}"

###############################################################################
# CHARGEMENT DES COULEURS
###############################################################################

# shellcheck disable=SC1090
source "${COLORS_FILE}"

###############################################################################
# FONCTIONS
###############################################################################

info() {
    printf '%b[INFO]%b %s\n' \
        "${LIGHT_GREEN}" \
        "${NONE}" \
        "$*"
}

warning() {
    printf '%b[ATTENTION]%b %s\n' \
        "${YELLOW}" \
        "${NONE}" \
        "$*" >&2
}

error() {
    printf '%b[ERREUR]%b %s\n' \
        "${LIGHT_RED}" \
        "${NONE}" \
        "$*" >&2
}

###############################################################################
# DETECTION DE LA DISTRIBUTION
###############################################################################

if [[ ! -r /etc/os-release ]]; then
    error "Impossible de déterminer la distribution."
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

info "Distribution détectée : ${PRETTY_NAME}"

###############################################################################
# NETTOYAGE DES FICHIERS GERES PAR CE SCRIPT
###############################################################################

info "Nettoyage des anciens fichiers MOTD..."

rm -f \
    "${MOTD_DIR}/00-headers" \
    "${MOTD_DIR}/10-banner" \
    "${MOTD_DIR}/20-sysinfo" \
    "${MOTD_DIR}/40-need-reboot" \
    "${MOTD_DIR}/50-services-need-restart"

###############################################################################
# VERIFICATION FIGLET
###############################################################################

if command -v figlet >/dev/null 2>&1; then
    info "figlet est déjà installé."
else
    warning "figlet n'est pas installé."
    info "Installation de figlet..."

    # apt-get update
    apt-get install -y figlet

    if ! command -v figlet >/dev/null 2>&1; then
        error "L'installation de figlet a échoué."
        exit 1
    fi

    info "figlet installé avec succès."

fi

###############################################################################
# VERIFICATION NEEDRESTART
###############################################################################

if command -v needrestart >/dev/null 2>&1; then
    info "needrestart est déjà installé."
else
    warning "needrestart n'est pas installé."
    info "Installation de needrestart..."

    # apt-get update
    apt-get install -y needrestart

    if ! command -v needrestart >/dev/null 2>&1; then
        error "L'installation de needrestart a échoué."
        exit 1
    fi

    info "needrestart installé avec succès."

fi

###############################################################################
# HOSTNAME
###############################################################################

info "Création du MOTD hostname..."

cat > "${MOTD_DIR}/00-headers" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC1091
source /etc/update-motd.d/colors

printf '\n'

printf '%b' "${LIGHT_RED}"

figlet "  $(hostname -s)"

printf '%b' "${NONE}"

printf '\n'
EOF

chmod 0755 "${MOTD_DIR}/00-headers"

###############################################################################
# BANNER
###############################################################################

info "Création du MOTD banner..."

cat > "${MOTD_DIR}/10-banner" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC1091
source /etc/update-motd.d/colors

DISTRIB_DESCRIPTION=""

###############################################################################
# RECUPERATION DES INFORMATIONS DISTRIBUTION
###############################################################################

if [[ -r /etc/update-motd.d/lsb-release ]]; then
    # shellcheck disable=SC1091
    source /etc/update-motd.d/lsb-release
fi

if [[ -z "${DISTRIB_DESCRIPTION}" ]] &&
   [[ -x /usr/bin/lsb_release ]]; then

    DISTRIB_DESCRIPTION="$(lsb_release -s -d)"

fi

###############################################################################
# MISE EN FORME DE LA DISTRIBUTION
###############################################################################

re='(.*\()(.*)(\).*)'

if [[ "${DISTRIB_DESCRIPTION}" =~ ${re} ]]; then

    DISTRIB_DESCRIPTION="$(
        printf '%s%s%s%s%s' \
            "${BASH_REMATCH[1]}" \
            "${YELLOW}" \
            "${BASH_REMATCH[2]}" \
            "${NONE}" \
            "${BASH_REMATCH[3]}"
    )"

fi

###############################################################################
# AFFICHAGE
###############################################################################

printf '  %b (kernel %s)\n\n' \
    "${DISTRIB_DESCRIPTION}" \
    "$(uname -r)"

###############################################################################
# CACHE DISTRIBUTION
###############################################################################

if command -v lsb_release >/dev/null 2>&1; then

    printf 'DISTRIB_DESCRIPTION="%s"\n' \
        "$(lsb_release -s -d)" \
        > /etc/update-motd.d/lsb-release

fi
EOF

chmod 0755 "${MOTD_DIR}/10-banner"

###############################################################################
# SYSINFO
###############################################################################

info "Création du MOTD sysinfo..."

cat > "${MOTD_DIR}/20-sysinfo" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# CPU
###############################################################################

CPU_CORES="$(nproc)"

CPU_MODEL="$(awk -F: '/model name/ {
    gsub(/^ /, "", $2)
    print $2
    exit
}' /proc/cpuinfo)"

###############################################################################
# RAM
###############################################################################

MEM_TOTAL="$(awk '/MemTotal:/ {
    print $2
}' /proc/meminfo)"

MEM_AVAILABLE="$(awk '/MemAvailable:/ {
    print $2
}' /proc/meminfo)"

###############################################################################
# UPTIME
###############################################################################

UPTIME="$(uptime -p)"

###############################################################################
# IP
###############################################################################

ADDR_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"

###############################################################################
# LOAD AVERAGE
###############################################################################

read -r ONE FIVE FIFTEEN REST < /proc/loadavg

###############################################################################
# AFFICHAGE
###############################################################################

printf '  Processeur : %s x %s\n' \
    "${CPU_CORES}" \
    "${CPU_MODEL}"

printf '  Charge CPU : %s (1min) / %s (5min) / %s (15min)\n' \
    "${ONE}" \
    "${FIVE}" \
    "${FIFTEEN}"

printf '  RAM : %sMB disponibles / %sMB\n' \
    "$((MEM_AVAILABLE / 1024))" \
    "$((MEM_TOTAL / 1024))"

# Séparation visuelle entre réseau et mémoire
printf '\n'

printf '  Adresse IP : %s\n' \
    "${ADDR_IP}"

printf '  Uptime : %s\n' \
    "${UPTIME}"

printf '\n'
EOF

chmod 0755 "${MOTD_DIR}/20-sysinfo"

###############################################################################
# NEED REBOOT
###############################################################################

info "Création du MOTD need-reboot..."

cat > "${MOTD_DIR}/40-need-reboot" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC1091
source /etc/update-motd.d/colors

if [[ -x /usr/sbin/needrestart ]]; then

    if DEBIAN_FRONTEND=noninteractive \
        /usr/sbin/needrestart -k -v -n 2>/dev/null |
        grep -q "Pending kernel upgrade!"; then

        printf '%b' "${LIGHT_RED}"

        printf '  Pending kernel upgrade! '

        printf '%b' "${NONE}"

        printf 'You should consider rebooting your machine.\n\n'

    fi

fi
EOF

chmod 0755 "${MOTD_DIR}/40-need-reboot"

###############################################################################
# SERVICES NEED RESTART
###############################################################################

info "Création du MOTD services-need-restart..."

cat > "${MOTD_DIR}/50-services-need-restart" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

source /etc/update-motd.d/colors

if [[ -x /usr/sbin/checkrestart ]]; then

    OUTPUT="$(
        /usr/sbin/checkrestart -p 2>/dev/null || true
    )"

    COUNT="$(
        printf '%s\n' "${OUTPUT}" |
        grep -oE 'Found [0-9]+ processes using old versions of upgraded files' |
        grep -oE '[0-9]+' |
        head -n 1 ||
        true
    )"

    COUNT="${COUNT:-0}"

    if [[ "${COUNT}" -gt 0 ]]; then

        printf '%b' "${LIGHT_RED}"

        printf '  %s services need to be restarted.\n' \
            "${COUNT}"

        printf '%b' "${NONE}"

        printf '  Use checkrestart to list and restart them.\n\n'

    fi

elif [[ -x /usr/sbin/needrestart ]]; then

    COUNT="$(
        /usr/sbin/needrestart -l -v -n -r l 2>/dev/null |
        grep -c "Skipping" ||
        true
    )"

    if [[ "${COUNT}" -gt 0 ]]; then

        printf '%b' "${LIGHT_RED}"

        printf '  %s services need to be restarted.\n' \
            "${COUNT}"

        printf '%b' "${NONE}"

        printf '  Use needrestart to list and restart them.\n\n'

    fi

fi
EOF

chmod 0755 "${MOTD_DIR}/50-services-need-restart"

###############################################################################
# CONFIGURATION /ETC/MOTD
###############################################################################

info "Configuration de /etc/motd..."
rm -f /etc/motd
ln -s /var/run/motd.dynamic.new /etc/motd

###############################################################################
# VERIFICATION SYNTAXIQUE
###############################################################################

info "Vérification syntaxique des scripts MOTD..."

for script in \
    "${MOTD_DIR}/00-headers" \
    "${MOTD_DIR}/10-banner" \
    "${MOTD_DIR}/20-sysinfo" \
    "${MOTD_DIR}/40-need-reboot" \
    "${MOTD_DIR}/50-services-need-restart"
do

    if bash -n "${script}"; then
        info "Syntaxe OK : ${script}"
    else
        error "Erreur de syntaxe : ${script}"
        exit 1
    fi

done

###############################################################################
# TEST DU MOTD
###############################################################################

printf '\n'
printf '%b' "${CYAN}"
printf '%s\n' '============================================================'
printf '%s\n' ' TEST DU MOTD'
printf '%s\n' '============================================================'
printf '%b\n' "${NONE}"

printf '\n'

if run-parts "${MOTD_DIR}"; then
    :
else
    error "Le test du MOTD a échoué."
    exit 1
fi

###############################################################################
# FIN
###############################################################################

printf '\n'
printf '%b' "${LIGHT_GREEN}"
printf '%s\n' '============================================================'
printf '%s\n' ' INSTALLATION TERMINEE'
printf '%s\n' '============================================================'
printf '%b\n' "${NONE}"
info "Reconnectez-vous en SSH pour afficher le MOTD."