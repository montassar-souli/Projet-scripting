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

#A vérier le type
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

#ps:on peut pas utiliser la commande cut car si un fichier contient des données on peut pas utiliser un simple espace commme un délimiteur
AcessFiles() {
	ls -l $1 | awk '{print $9, $1}'
}

PropFiles() {
ls -l $1 | awk '{print $9, $3}'
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



#while getopts ":hgvm" opt
#do


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




