#!/usr/bin/env bash

# Vérifier le nombre d'argument
if [ $# -ne 1 ]; then
    echo "Ce script nécessite un argument : chemin du fichier txt avec les urls"
    exit 
fi

#Assigner le premier argument à la variable URLS
URLS=$1 
#Extraire le nom du fichier sans extension à partir du premier argument pour avoir la langue des sites
lang=$(basename $URLS .txt)  
#Construire le nom de fichier html en fonction de la langue
output_file="tableaux/tableau-${lang}.html"

#Déterminer la valeur de la variable $mot en fonction la langue extraite précédemment
if [[ $lang = 'FR' ]]; then mot="héritage" langfull="français"; 
elif [[ $lang = 'EN' ]]; then mot="heritage" langfull="anglais";
else mot="상속" langfull="coréen"; 
fi
echo "mot value: ${mot}" #Pour debug

#Initialiser le compteur afin de pouvoir numéroter les fichiers
N=1

########### Création page HTML dans $output_file #########################################
echo "<!DOCTYPE html>
<html>
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <title>PPE Projet - Tableau</title>
    <!-- Inclure la feuille de style Bulma -->
    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.3/css/bulma.min.css\">

</head>

<body>
    <!-- Barre de navigation -->
    <nav class=\"navbar\" role=\"navigation\" aria-label=\"main navigation\">
        <div class=\"navbar-brand\">
            <a class=\"navbar-item\" href=\"#\">
                <h1 class=\"title is-4\">PPE Projet</h1>
            </a>
        </div>

        <div id=\"navbar\" class=\"navbar-menu\">
            <div class=\"navbar-start\">
                <a class=\"navbar-item\" href=\"../index.html\">
                    Accueil
                </a>

                <a class=\"navbar-item\" href=\"tableau-FR.html\">
                    Tableau FR
                </a>
                <a class=\"navbar-item\" href=\"tableau-EN.html\">
                    Tableau EN
                </a>
                <a class=\"navbar-item\" href=\"tableau-KR.html\">
                    Tableau KR
                </a>

            </div>
        </div>
    </nav>

    <!-- Héros -->
    <section class=\"hero is-info is-bold\">
        <div class=\"hero-body\">
            <div class=\"container\">
                <h1 class=\"title\">Tableau des URLs ${langfull}</h1>
                <p class=\"subtitle\">Mot en ${langfull} : ${mot}</p>
            </div>
        </div>
    </section>" > "$output_file"

echo "<!-- Section avec le tableau -->
<section class=\"section\">
        <div class=\"table is-bordered is-narrow is-hoverable is-fullwidth\">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>URL</th>
                        <th>HTTP Code</th>
                        <th>Charset</th>
                        <th>dump-html</th>
                        <th>dump-txt</th>
                        <th>Compte</th>
                        <th>Contexte</th>
                        <th>Concordancier</th>
                    </tr>
                </thead>
                <tbody>" >> "$output_file"
                
##########################################################################################

#Boucle qui lit chaque ligne du fichier contenant les liens (variable $URLS) 
while read -r line
do
	#Construire les chemins des fichiers en fonction de la langue et du numéro de ligne
	html="aspirations/${lang}-${N}.html" 
	txt="dumps-text/${lang}-${N}.txt"
	context="contextes/${lang}-${N}.txt"
	concord="concordances/${lang}-${N}.html"
	
	#Télécharger le contenu de l'URL de la ligne et l'enregistrer dans $html
	#curl -Lo "$html" $line
	curl -Lo "$html" -b /dev/null "$line"
	#Extraire le texte brut de la page HTML téléchargée et l'enregistrer dans $txt
	lynx --dump --nolist --assume-charset=UTF-8 --display-charset=UTF-8 "$html" > "$txt"
	#Extraire le code HTTP
	code=$(curl -o /dev/null -s -w "%{http_code}\n" -L $line) 
	#Extraire le charset
	charset=$(curl -s -I -L -w "%{content_type}" -o /dev/null $line | grep -E -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)
	#Compter le nombre d'occurrences de $mot
	compte=$(cat "$txt" | ggrep -Poi "${mot}" | wc -l)
	#Extraire le contexte
	#ggrep -Poi ".*${mot}.*" "$txt" > "$context"
	#cat "$txt" | tr '^$' ' ' | ggrep -Pi "^.*$.*${mot}.*^.*$" > "$context"
	#grep -i -A 1 -B 1 "${mot}" "$txt" > "$context"
	cat "$txt" | grep -i -A 1 -B 1 "${mot}" > "$context"
	
########## Concordancier qui ne fonctionne pas ###########################################

	#left=$(cat "$context" | grep -i -B 1 "${mot}" | head -n 1)
    #right=$(cat "$context" | grep -i -A 1 "${mot}" | tail -n 1)
    echo "<html>
    		<table>
                <thead>
                    <tr>
                        <th>contexte gauche</th>
                        <th>cible</th>
                        <th>contexte droit</th>
                    </tr>
                </thead>
                <tbody>" > "$concord"
                
    while read -r context_line; do
        #left=$(echo "$context_line" | grep -i -B 1 "${mot}" | head -n 1)
        #right=$(echo "$context_line" | grep -i -A 1 "${mot}" | tail -n 1)
        left=$(egrep -i -B 1 "${mot}" | head -n 1)
   		right=$(egrep -i -A 1 "${mot}" | tail -n 1)
        
        echo "<tr><td>$left</td><td>$mot</td><td>$right</td></tr>" >> "$concord"
    done < "$context"            
                
    #echo "<tr><td>$left</td><td>$mot</td><td>$right</td></tr>" >> "$concord"
    
    echo "			</tbody>
       		 </table>
   		 </html>" >> "$concord" 
   		 
##########################################################################################

	#Ecrire une ligne du tableau HTML
	echo "        <tr>
            <td>$N</td>
            <td><a href=$line>$line</a></td>
            <td>$code</td>
            <td>$charset</td>
            <td><a href=../$html>html</a></td>
            <td><a href=../$txt>txt</a></td>
            <td>$compte</td>
            <td><a href=../$context>context</a></td>
            <td><a href=../$concord>concordancier</a></td>
            
        		</tr>" >> "$output_file"	
    
        		     			
	
	N=$((N + 1)) #Incrémenter le compteur
done < $URLS #Fin de la boucle

#Ecrire la fin du fichier HTML
echo "</tbody>
        </table>
   	 </div>
    </section>
</body>
</html>" >> "$output_file"

echo "Le fichier HTML a été créé : $output_file"