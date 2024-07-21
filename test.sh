#!/bin/bash

show_usage() {
	echo 'inforep.sh: [-h|--help] [-g] [-v] [-m] chemain..'
}

HELP() {
	cat help.txt
}

AfficheNbF() {
	echo "Nombre des fichier dans le dossier $1 est : $(ls -l $1 | grep ^- | wc -l)"
}

AfficeNbD() {
	echo "Nombre de dossiers dans le repertoire $1 est : $(ls -l $1 | grep ^d | wc -l)"
}

#A vérier le type
TypeFiles() {
	echo "$1 est un dossier"
}

#ps:on peut pas utiliser la commande cut car si un fichier contient des données on peut pas utiliser un simple espace commme un délimiteur
AcessFiles() {
	ls -l $1 | awk '{print $9, $1}'
}

PropFiles() {
ls -l $1 | awk '{print $9, $3}'
}

stat() {
    local dir="$1"
    local nb_files=$(AfficheNbF "$dir")
    local nb_dirs=$(AfficheNbD "$dir")

    echo "Nombre de fichiers : $nb_files"
    echo "Nombre de dossiers : $nb_dirs"

    # Création du fichier de données pour gnuplot
    echo -e "Type\tCount\nFiles\t$nb_files\nDirectories\t$nb_dirs" > /tmp/datafile.dat

    # Création du script gnuplot
    gnuplot -persist <<-EOFMarker
        set title "Statistiques de $dir"
        set style data histograms
        set style fill solid 1.0 border -1
        set xlabel "Type"
        set ylabel "Count"
        plot "/tmp/datafile.dat" using 2:xtic(1) title ""
EOFMarker
}
TypeFile() {
	echo "$1 est un fichier"
	ls -l $1
}

AcessFile() {
	permissions=$(ls -l "$1" | cut -d' ' -f1)
	echo "Owner : ${permissions:1:3}"
	echo "Group : ${permissions:4:3}"
	echo "Others: ${permissions:7:3}"
}

PropFile() {
	echo "Propriétaire : $(ls -l "$1" | cut -d' ' -f3)"
	echo "Groupe       : $(ls -l "$1" | cut -d' ' -f4)"	
}

Ecriture() {
	permissions=$(ls -l "$1" | cut -d' ' -f1)
	proprio=$(ls -l "$1" | cut -d' ' -f3)
	groupe=$(ls -l "$1" | cut -d' ' -f4)
	echo "Permissions  : $permissions"

	if [[ ${permissions:2:1} == w ]] then
		echo "Propriétaire : $proprio a le droit d'écriture"
	fi
	if [[ ${permissions:5:1} == w ]] then
		echo "Groupe       : $groupe a le droit d'écriture"
	fi
	if [[ ${permissions:8:1} == "w" ]] then
		echo "Autre a le droit d'écriture"
	else echo "Aucun utilisateur avec le droit d'écriture"
	fi
}



# Function to display a graphical menu with YAD
graphical_menu() {
    local choices=()
    if [ -d "$1" ]; then
        choices=("Afficher le nombre de fichiers" "Afficher le nombre de dossiers" "Afficher les types de fichiers" "Afficher les noms des fichiers et les droits d’accès" "Afficher les noms des fichiers et les propriétaires" "Afficher les statistiques" "Aide" "Fermer")
    elif [ -f "$1" ]; then
        choices=("Afficher le type de fichier" "Afficher les droits d’accès" "Afficher le groupe et le propriétaire de fichier" "Afficher les utilisateurs avec le droit d’écriture de fichier" "Aide" "Fermer")
    else
        echo "Type non défini ou introuvable"
        exit 1
    fi

    local choice=$(yad --list --radiolist --column "Choix" --column "Action" FALSE "${choices[@]}" --title="Menu" --width=500 --height=300 --button="gtk-ok:0" --button="gtk-cancel:1")

    case $choice in
        "Afficher le nombre de fichiers")
            AfficheNbF "$1"
            ;;
        "Afficher le nombre de dossiers")
            AfficeNbD "$1"
            ;;
        "Afficher les types de fichiers")
            TypeFiles "$1"
            ;;
        "Afficher les noms des fichiers et les droits d’accès")
            AcessFiles "$1"
            ;;
        "Afficher les noms des fichiers et les propriétaires")
            PropFiles "$1"
            ;;
        "Afficher les statistiques")
            stat "$1"
            ;;
        "Afficher le type de fichier")
            TypeFile "$1"
            ;;
        "Afficher les droits d’accès")
            AcessFile "$1"
            ;;
        "Afficher le groupe et le propriétaire de fichier")
            PropFile "$1"
            ;;
        "Afficher les utilisateurs avec le droit d’écriture de fichier")
            Ecriture "$1"
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

# Parse options
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
            echo "Auteurs : VotreNom"
            echo "Version : 1.0"
            exit 0
            ;;
        m )
            # Add your text menu handling here
            echo "Option menu non implémentée"
            exit 0
            ;;
        \? )
            show_usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# If no arguments left, show usage
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# If -g option is used, call the graphical menu function
if [ "$GRAPHICAL_MENU" = true ]; then
    for arg in "$@"; do
        graphical_menu "$arg"
    done
    exit 0
fi


if [ $# -eq 0 ]; then
	show_usage
	exit 1
fi

for arg in $*; do
	if [ -d $arg ]; then
		PS3="Votre choix :"
		select choix in "Afficher le nombre de fichiers" "Afficher le nombre de dossiers" "Afficher les types de fichiers" "Afficher les noms des fichiers et les droits d’accès" "Afficher les noms des fichiers et les propriétaires" "Afficher les statistiques" "Aide" "Fermer";
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
					PropFile $arg
					;;
				4)
					AcessFiles $arg
					;;
				5)
					PropFiles $arg
					;;
				6)
					stat
					;;
				7)
					HELP
					;;
				8)
					exit 0
					;;
				*)
					echo "Choix inccorect"
					;;		
			esac
		done    
    	else if [ -f $arg ]; then
    		PS3="Votre choix :"
    		select choix in "Afficher le type de fichier" "Afficher les droits d’accès" "Afficher le group et le propriétaire de fichier" "Afficher les utilisateurs avec le droit d’écriture de fichier" "Aide" "Fermer";
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
						echo "Choix inccorect"
						;;		
				esac
			done    
    	else echo "Type non défini ou introuvale"
    	fi
	fi
done




