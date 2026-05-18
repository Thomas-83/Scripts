## Configuration GNOME-SHELL

#!/bin/bash

# Tester si root
if [[ $(id -u) -eq "0" ]]
then
	echo -e "\033[31mATTENTION\033[0m Si vous lancez ce script en root, cela personnalisera la session GNOME de root !"
	echo "Poursuite du script dans 10 secondes..."
	sleep 10
fi

echo "Configuration générale de GNOME"
echo " - Boutons de fenêtre"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
echo " - Détacher les popups des fenêtres"
gsettings set org.gnome.mutter attach-modal-dialogs false
echo " - Affichage du calendrier dans le panneau supérieur"
gsettings set org.gnome.desktop.calendar show-weekdate true
echo " - Modification du format de la date et heure"
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds false
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface clock-format 24h
echo " - Localisation du pointeur via CTRL"
gsettings set org.gnome.desktop.interface locate-pointer true
echo " - Désactivation des sons système"
gsettings set org.gnome.desktop.wm.preferences audible-bell false
echo " - Timeout des applications en attente de réponse à 60s"
gsettings set org.gnome.mutter check-alive-timeout 60000
echo " - Epuration des fichiers temporaires et de la corbeille de plus de 30 jours"
gsettings set org.gnome.desktop.privacy remove-old-temp-files true
gsettings set org.gnome.desktop.privacy remove-old-trash-files true
gsettings set org.gnome.desktop.privacy old-files-age "30"
echo "Confidentialité de GNOME"
echo " - Désactivation de l'envoi des rapports"
gsettings set org.gnome.desktop.privacy report-technical-problems false
echo " - Désactivation des statistiques des logiciels"
gsettings set org.gnome.desktop.privacy send-software-usage-stats false
echo " - Application du thème sombre"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-Dark'
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
echo " - Désactivation de l'envoi des rapports"
gsettings set org.gnome.desktop.privacy report-technical-problems false
echo " - Désactivation des statistiques des logiciels"
gsettings set org.gnome.desktop.privacy send-software-usage-stats false
echo "Personnalisation de GNOME"
echo " - Application du thème sombre"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
echo "Configuration Nautilus"
echo " - Désactivation de l ouverture du dossier lorsqu un élément est glissé dedans"
gsettings set org.gnome.nautilus.preferences open-folder-on-dnd-hover false
gsettings set org.gnome.nautilus.preferences show-delete-permanently true
echo " - Activation du double clic"
gsettings set org.gnome.nautilus.preferences click-policy 'double'
echo "Personnalisation de Ptyxis"
gsettings set org.gnome.Ptyxis audible-bell 'false'
gsettings set org.gnome.Ptyxis restore-window-size 'true'
gsettings set org.gnome.Ptyxis scrollbar-policy 'always'
echo "Personnalisation de Dash-to-dock"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "LEFT"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
echo " - Correction du bug de la double lettre"
gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
echo "- Applications épinglées"
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop', 'thunderbird.desktop', 'org.gnome.Ptyxis.desktop', 'signal-desktop.desktop', 'codium.desktop', 'transmission-gtk.desktop', 'org.gnome.TextEditor.desktop', 'org.keepassxc.KeePassXC.desktop']"

echo "Personnalisation terminée."


