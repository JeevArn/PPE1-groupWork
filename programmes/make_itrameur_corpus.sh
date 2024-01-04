#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "le script nécessite 3 arguments : le chemin du dossier dumps-txt, le chemin du dossier contextes et la langue"
    exit 1
fi

dossier_dump="$1"
dossier_context="$2"
lang="$3"

output_dump="itrameur/dump-${lang}.txt"
echo "<lang=\"${lang}\">" > "$output_dump"

output_context="itrameur/contexte-${lang}.txt"
echo "<lang=\"${lang}\">" > "$output_context"

#pour la normalisation
if [[ $lang = 'FR' ]]; then mot="héritage" motif="[Hh][ée]ritages?|H[ÉE]RITAGES?";  
elif [[ $lang = 'EN' ]]; then mot="heritage" motif="[Hh]eritage|HERITAGE";
else mot="상속" motif="상속|상속은|상속이|상속울"; 
fi

# Parcours de tous les fichiers du dossier dump en fonction de la langue
for fichier in "$dossier_dump"/"${lang}"*.txt; do
    if [ -f "$fichier" ]; then
        # Extraction du numéro de page à partir du nom du fichier
		page=$(basename "$fichier" .txt)
        # Suppression des &<>§
        texte=$(cat "$fichier" | tr -d '&<>§')
        # Ajout des balises au fichier de sortie
        echo "<page=\"${page}\">" >> "$output_dump"
        # Substitution des caractères spéciaux xml dans le texte
        #echo "<text>$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$fichier")</text>" >> "$output"
        echo "<text>${texte}</text>" >> "$output_dump"
        echo "</page> §" >> "$output_dump"
    fi
done
echo "</lang>" >> "$output_dump"


# Parcours de tous les fichiers du dossier context en fonction de la langue
for fichier in "$dossier_context"/"${lang}"*.txt; do
    if [ -f "$fichier" ]; then
        # Extraction du numéro de page à partir du nom du fichier
		page=$(basename "$fichier" .txt)
        # Suppression des &<>§
        texte=$(cat "$fichier" | tr -d '&<>§' | sed -E "s/$motif/$mot/g")
        # Ajout des balises au fichier de sortie
        echo "<page=\"${page}\">" >> "$output_context"
        # Substitution des caractères spéciaux xml dans le texte
        #echo "<text>$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$fichier")</text>" >> "$output_context"
        echo "<text>${texte}</text>" >> "$output_context"
        echo "</page> §" >> "$output_context"
    fi
done
echo "</lang>" >> "$output_context"

#on utilisera les fichiers contextes pour faire notre analyse sur itrameur
#mais itrameur ne supporte pas les regex donc on remplace toutes les variations par un seul mot pour obtenir toutes les cooccurrences par la suit
#sed -E "s/$motif/$mot/g" "$output_contex"





