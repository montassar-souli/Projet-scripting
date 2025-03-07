#!/bin/bash

show_usage() {
    echo 'inforep.sh: [-h|--help] [-g] [-v] [-m] chemain..'
}

HELP() {
    cat help.txt
}

AfficheNbF() {
    echo "Nombre des fichiers dans le repertoire $1 est : $(ls -l $1 | grep ^- | wc -l)"
}

AfficeNbD() {
    echo "Nombre des dossiers dans le repertoire $1 est : $(ls -l $1 | grep ^d | wc -l)"
}

#A vérifier le type
TypeFiles() {
    for i in $1/*; do
        nom=$(basename "$i")
        if [ -d $i ]; then
            echo "$nom est un dossier"
        elif [ -f $i ]; then
            echo "$nom est un fichier"
        else
            echo "$nom est inconnu"
        fi
    done
}

#ps:on ne peut pas utiliser la commande cut car si un fichier contient des données on ne peut pas utiliser un simple espace comme un délimiteur
AcessFiles() {
    ls -l $1 | grep -v '^total' | awk '{print $9, $1}'
}

PropFiles() {
    ls -l $1 | awk 'NF >= 9 {print $9, $3}'
}

#sudo apt install gnuplot
stat() {
    gnuplot -persist <<-EOFMarker
        set title "Statistiques de $1"
        set style data histograms
        set style fill solid 1.0 border -1
        set xlabel "Types"
        set ylabel "Nombre"
        set yrange [0:*]
        plot '-' using 2:xtic(1) title "" 
        "Fichier" $(ls -l $1 | grep ^- | wc -l)
        "Dossier" $(ls -l $1 | grep ^d | wc -l)        
EOFMarker
}
TypeFile() {
    type=$(file --mime-type -b "$1")
    echo "$1 est un fichier de type $type"
}

AcessFile() {
    permissions=$(ls -l "$1" | cut -d' ' -f1)
    echo "Propriétaire : ${permissions:1:3}"
    echo "Groupe       : ${permissions:4:3}"
    echo "Autre        : ${permissions:7:3}"
}

PropFile() {
    echo "Propriétaire : $(ls -l "$1" | cut -d' ' -f3)"
    echo "Groupe       : $(ls -l "$1" | cut -d' ' -f4)"    
}

Ecriture() {
    permissions=$(ls -l "$1" | awk '{print $1}')
    proprio=$(ls -l "$1" | awk '{print $3}')
    groupe=$(ls -l "$1" | awk '{print $4}')
    echo "Permissions  : $permissions"

    permission=false

    if [[ ${permissions:2:1} == "w" ]]; then
        echo "Propriétaire : $proprio a le droit d'écriture"
        permission=true
    fi
    if [[ ${permissions:5:1} == "w" ]]; then
        echo "Groupe       : $groupe a le droit d'écriture"
        permission=true
    fi
    if [[ ${permissions:8:1} == "w" ]]; then
        echo "Autre        : a le droit d'écriture"
        permission=true
    fi
    if [[ $permission == false ]]; then
        echo "Aucun utilisateur avec le droit d'écriture"
    fi
}

menu_dossier() {
    local dir="$1"
    local choice=$(yad --list --radiolist --column "Choix" --column "Action" \
        FALSE "Afficher le nombre de fichiers" \
        FALSE "Afficher le nombre de dossiers" \
        FALSE "Afficher les types de fichiers" \
        FALSE "Afficher les noms des fichiers et les droits d’accès" \
        FALSE "Afficher les noms des fichiers et les propriétaires" \
        FALSE "Afficher les statistiques" \
        FALSE "Aide" \
        FALSE "Fermer" \
        --title="Menu Fichier" --width=500 --height=300 --button="gtk-ok:0" --button="gtk-cancel:1")
    choice=$(echo $choice | cut -d '|' -f 2)
    case $choice in
        "Afficher le nombre de fichiers")
            AfficheNbF "$dir"
            ;;
        "Afficher le nombre de dossiers")
            AfficeNbD "$dir"
            ;;
        "Afficher les types de fichiers")
            TypeFiles "$dir"
            ;;
        "Afficher les noms des fichiers et les droits d’accès")
            AcessFiles "$dir"
            ;;
        "Afficher les noms des fichiers et les propriétaires")
            PropFiles "$dir"
            ;;
        "Afficher les statistiques")
            stat "$dir"
            ;;
        "Aide")
            HELP
            ;;
        "Fermer")
            exit 0
            ;;
        *)
            echo "Choix incorrect"
            ;;
    esac
}

menu_fichier() {
    local file="$1"
    local choice=$(yad --list --radiolist --column "Choix" --column "Action" \
        FALSE "Afficher le type de fichier" \
        FALSE "Afficher les droits d’accès" \
        FALSE "Afficher le groupe et le propriétaire de fichier" \
        FALSE "Afficher les utilisateurs avec le droit d’écriture de fichier" \
        FALSE "Aide" \
        FALSE "Fermer" \
        --title="Menu Fichier" --width=500 --height=300 --button="gtk-ok:0" --button="gtk-cancel:1")

    choice=$(echo $choice | cut -d '|' -f 2)

    case $choice in
        "Afficher le type de fichier")
            TypeFile "$file"
            ;;
        "Afficher les droits d’accès")
            AcessFile "$file"
            ;;
        "Afficher le groupe et le propriétaire de fichier")
            PropFile "$file"
            ;;
        "Afficher les utilisateurs avec le droit d’écriture de fichier")
            Ecriture "$file"
            ;;
        "Aide")
            HELP
            ;;
        "Fermer")
            exit 0
            ;;
        *)
            echo "Choix incorrect"
            ;;
    esac
}

menu_dossier_text() {             
    PS3="Votre choix : "
    options=("Afficher le nombre de fichiers" "Afficher le nombre de dossiers" "Afficher les types de fichiers" "Afficher les noms des fichiers et les droits d’accès" "Afficher les noms des fichiers et les propriétaires" "Afficher les statistiques" "Aide" "Fermer")
    select opt in "${options[@]}"
    do
        case $opt in
            "Afficher le nombre de fichiers")
                AfficheNbF $1
                ;;
            "Afficher le nombre de dossiers")
                AfficeNbD $1
                ;;
            "Afficher les types de fichiers")
                TypeFiles $1
                ;;
            "Afficher les noms des fichiers et les droits d’accès")
                AcessFiles $1
                ;;
            "Afficher les noms des fichiers et les propriétaires")
                PropFiles $1
                ;;
            "Afficher les statistiques")
                stat $1
                ;;
            "Aide")
                HELP
                ;;
            "Fermer")
                exit 0
                ;;
            *)
                echo "Choix incorrect"
                ;;        
        esac
    done  
}

menu_fichier_text() {
    PS3="Votre choix : "
    options=("Afficher le type de fichier" "Afficher les droits d’accès" "Afficher le groupe et le propriétaire de fichier" "Afficher les utilisateurs avec le droit d’écriture de fichier" "Aide" "Fermer")
    select opt in "${options[@]}"
    do
        case $opt in
            "Afficher le type de fichier")
                TypeFile $1
                ;;
            "Afficher les droits d’accès")
                AcessFile $1
                ;;
            "Afficher le groupe et le propriétaire de fichier")
                PropFile $1
                ;;
            "Afficher les utilisateurs avec le droit d’écriture de fichier")
                Ecriture $1
                ;;
            "Aide")
                HELP
                ;;
            "Fermer")
                exit 0
                ;;
            *)
                echo "Choix incorrect"
                ;;        
        esac
    done  
}

#options
while getopts ":hgvms:" opt; do
    case ${opt} in
        h )
            HELP
            exit 0
            ;;
        g )
            GRAPHICAL_MENU=true
            ;;
        v )
            echo "Auteurs : Montassar Souli & Zied Ben Salah"
            echo "Version : 1.0"
            exit 0
            ;;
        m )
            TEXTUAL_MENU=true
            ;;
        \? )
            show_usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi
#sudo apt install yad
if [ "$GRAPHICAL_MENU" = true ]; then
    for arg in "$@"; do
        if [ -d "$arg" ]; then
            menu_dossier "$arg"
        elif [ -f "$arg" ]; then
            menu_fichier "$arg"
        else
            echo "Type non défini ou introuvable"
            exit 1
        fi
    done
    exit 0
fi

if [ "$TEXTUAL_MENU" = true ]; then
    for arg in "$@"; do
        if [ -d "$arg" ]; then
            menu_dossier_text "$arg"
        elif [ -f "$arg" ]; then
            menu_fichier_text "$arg"
        else
            echo "Type non défini ou introuvable"
            exit 1
        fi
    done
    exit 0
fi

for arg in $*; do
    if [ -d $arg ]; then
        PS3="Votre choix : "
        select choix in "Afficher le nombre de fichiers" "Afficher le nombre de dossiers" "Afficher les types de fichiers" "Afficher les noms des fichiers et les droits d’accès" "Afficher les noms des fichiers et les propriétaires" "Afficher les statistiques" "Aide" "Fermer"
        do
            echo "Vous avez choisi : $choix"
            case $REPLY in
                1)
                    AfficheNbF $arg
                    ;;
                2)
                    AfficeNbD $arg
                    ;;
                3)
                    TypeFiles $arg
                    ;;
                4)
                    AcessFiles $arg
                    ;;
                5)
                    PropFiles $arg
                    ;;
                6)
                    stat $arg
                    ;;
                7)
                    HELP
                    ;;
                8)
                    exit 0
                    ;;
                *)
                    echo "Choix incorrect"
                    ;;        
            esac
        done    
    elif [ -f $arg ]; then
        PS3="Votre choix : "
        select choix in "Afficher le type de fichier" "Afficher les droits d’accès" "Afficher le groupe et le propriétaire de fichier" "Afficher les utilisateurs avec le droit d’écriture de fichier" "Aide" "Fermer"
        do
            echo "Vous avez choisi : $choix"
            case $REPLY in
                1)
                    TypeFile $arg
                    ;;
                2)
                    AcessFile $arg
                    ;;
                3)
                    PropFile $arg
                    ;;
                4)
                    Ecriture $arg
                    ;;
                5)
                    HELP
                    ;;
                6)
                    exit 0
                    ;;
                *)
                    echo "Choix incorrect"
                    ;;        
            esac
        done    
    else
        echo "Type non défini ou introuvable"
    fi
done

