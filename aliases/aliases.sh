
# Alias de navigation et listing
alias -='cd -'
alias ...=../..
alias ....=../../..
alias .....=../../../..
alias ......=../../../../..
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -al'
alias llh='ls -alh'
alias ls='ls --color=tty'
alias lsa='ls -lah'
alias md='mkdir -p'


# Raccourcis pratiques
alias c='clear'
alias ports='netstat -tulanp'
alias untarbz2='tar -jxvf'
alias untargz='tar -zxvf'
alias watch='watch --color'
alias which-command=whence
alias NeedReboot='cat /var/run/reboot-required ; cat /var/run/reboot-required.pkgs'
alias efface_disque='sudo shred --zero --verbose --force --iterations=5'
alias egrep='grep -E'
alias fgrep='grep -F'
alias flush_dns='sudo resolvectl flush-caches'
alias grep='grep --color -i'
alias ip='ip --color'
alias tree='tree -a'

# Mises à jour
alias mise_a_jour='sudo apt update && echo -e "\e[36m #### Installation des paquets  ####\e[0m" && sudo apt full-upgrade -y && echo "\e[36m #### Nettoyage des paquets obsolètes ####\e[0m" && sudo apt autoremove -y && echo "\e[36m #### Recherche et nettoyage des résidus de configuration  ####\e[0m" && sudo aptitude search "~c" && sudo aptitude purge "~c" ; NeedReboot'

# Exemple de fonction (compatible Bash et Zsh)
#mkcd() {
#    mkdir -p "$1" && cd "$1"
#}
