#!/bin/bash
# Récupéré depuis https://blog.genma.fr/Ubuntu-et-nettoyage-des-paquets-snap.html
#
# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu

LANG=C snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
