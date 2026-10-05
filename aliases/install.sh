#!/bin/bash

set -euo pipefail

# Date pour le suffixe de sauvegarde (ex: 2026-10-05)
DATE_SUFFIX=$(date +%Y-%m-%d)

# Détermine le chemin absolu du fichier d'alias
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIAS_FILE="$DIR/aliases.sh"

if [ ! -f "$ALIAS_FILE" ]; then
    echo "❌ Erreur : Le fichier $ALIAS_FILE est introuvable."
    exit 1
fi

injecter_alias() {
    local TARGET_RC="$1"
    local SOURCE_CMD="[ -f \"$ALIAS_FILE\" ] && . \"$ALIAS_FILE\""

    if [ -f "$TARGET_RC" ]; then
        if ! grep -Fq "$SOURCE_CMD" "$TARGET_RC"; then
            # Création de la sauvegarde avant modification
            local BACKUP_FILE="${TARGET_RC}.${DATE_SUFFIX}.bak"
            cp "$TARGET_RC" "$BACKUP_FILE"
            echo "📦 Sauvegarde créée : $BACKUP_FILE"

            echo -e "\n# Chargement des alias personnalisés (Git)\n$SOURCE_CMD" >> "$TARGET_RC"
            echo "✅ Inclusion ajoutée avec succès dans $TARGET_RC"
        else
            echo "ℹ️  L'inclusion est déjà présente dans $TARGET_RC."
        fi
    else
        echo "⚠️  Création du fichier $TARGET_RC..."
        echo -e "# Chargement des alias personnalisés (Git)\n$SOURCE_CMD" > "$TARGET_RC"
        echo "✅ Fichier créé et inclusion ajoutée."
    fi
}

installer_global() {
    local TARGET="/etc/profile.d/aliases.sh"
    
    # Création de la sauvegarde globale si le fichier existe déjà
    if [ -f "$TARGET" ]; then
        local BACKUP_FILE="${TARGET}.${DATE_SUFFIX}.bak"
        echo "📦 Sauvegarde du fichier existant : $BACKUP_FILE"
        sudo cp "$TARGET" "$BACKUP_FILE"
    fi

    echo "⚙️  Installation globale dans $TARGET..."
    if sudo cp "$ALIAS_FILE" "$TARGET"; then
        sudo chmod 644 "$TARGET"
        echo "✅ Alias déployés pour tous les utilisateurs."
    else
        echo "❌ Échec de l'installation globale."
        exit 1
    fi
}

echo "Où souhaitez-vous installer vos alias ?"
echo "1) Tous les utilisateurs (Nécessite sudo - /etc/profile.d/)"
echo "2) Bash uniquement (~/.bashrc)"
echo "3) Zsh uniquement (~/.zshrc)"
echo "4) Utilisateur actuel (Bash et Zsh)"
echo "5) Quitter"
read -p "Votre choix (1-5) : " CHOIX

echo ""

case $CHOIX in
    1) installer_global ;;
    2) injecter_alias "$HOME/.bashrc" ;;
    3) injecter_alias "$HOME/.zshrc" ;;
    4) 
        injecter_alias "$HOME/.bashrc"
        injecter_alias "$HOME/.zshrc"
        ;;
    5)
        echo "Installation annulée."
        exit 0
        ;;
    *)
        echo "❌ Choix invalide."
        exit 1
        ;;
esac

echo ""
echo "🔄 Rechargement du terminal..."
exec "$SHELL"
