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
if [[ $lang = 'FR' ]]; then mot="héritage" langfull="français" motif="[Hh][ée]ritages?|H[ÉE]RITAGES?";  
elif [[ $lang = 'EN' ]]; then mot="heritage" langfull="anglais" motif="[Hh]eritage|HERITAGE";
else mot="상속" langfull="coréen" motif="상속|상속은|상속이|상속울"; 
fi
echo "mot value: ${mot}" #Pour debug
echo "motif value: ${motif}" #Pour debug

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
                <a class=\"navbar-item\" href=\"../pages/equipe.html\">
                    Equipe
                </a>
                <a class=\"navbar-item\" href=\"../pages/demarche.html\">
                    Démarche
                </a>
                <a class=\"navbar-item\" href=\"../pages/analyse.html\">
                    Analyse
                </a>
    
                <div class=\"navbar-item has-dropdown is-hoverable\">
                	<a class=\"navbar-link\">
          				Tableaux
        			</a>
                	<div class=\"navbar-dropdown\">
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
                
                <div class=\"navbar-item has-dropdown is-hoverable\">
                	<a class=\"navbar-link\">
          				Code
        			</a>
                	<div class=\"navbar-dropdown\">
                		<a class=\"navbar-item\" href=\"../pages/scriptPrincipale.html\">
                    		Script principale
                		</a>
                		<a class=\"navbar-item\" href=\"../pages/scriptItrameur.html\">
                    		Script iTrameur
                		</a>
                		<a class=\"navbar-item\" href=\"../pages/scriptMain.html\">
                    		Script \"main\"
                		</a>
                	</div>
                </div>
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
	#Extraire le code HTTP
	code=$(curl -o /dev/null -s -w "%{http_code}\n" -L $line) 
	#Extraire le charset
	#charset=$(curl -s -I -L -w "%{content_type}" -o /dev/null $line | grep -E -o "(charset=[\"\']?)(.{,15})([\"\'>/ ])" | awk -F '[()]' '{print $2}')
	charset=$(curl -s -I -L -w "%{content_type}" -o /dev/null $line | grep -E -o "(charset=)([^\"\'>/ ]+)" | awk -F= '{print $2}' | tr -d '\r' | tr '[:lower:]' '[:upper:]') #| awk -F '[()]' '{print $2}')
	
	echo "charset pre iconv : $charset" #pour debug
	echo "num : $N" #pour debug
	
	#Si le site fonctionne
	if [ $code -eq 200 ]; then
		#Construire les chemins des fichiers en fonction de la langue et du numéro de ligne
		html="aspirations/${lang}-${N}.html" 
		txt="dumps-text/${lang}-${N}.txt"
		context="contextes/${lang}-${N}.txt"
		concord="concordances/${lang}-${N}.html"
	
		#Télécharger le contenu de l'URL de la ligne et l'enregistrer dans $html si UTF-8 sinon conversion

		if [ ! $charset == "UTF-8" ]; then #corr
			curl "$line" | iconv -f "$charset" -t utf-8 > "$html";
		else 
			curl -Lo "$html" -b /dev/null "$line";
		fi

		#Extraire l'encodage après conversion en utf-8
		while read -r ligne; do
    	if [[ $ligne == *charset=* ]]; then
        	if [[ $ligne =~ (charset=)([\"\']?)(.{5})([\"\'>/ ]) ]]; then
           	 	encodage=${BASH_REMATCH[3]}
        	fi
   	 	fi
		done < "$html"
		
		echo "Encodage post iconv : $encodage" #pour debug
			
		#Extraire le texte brut de la page HTML téléchargée et l'enregistrer dans $txt
		lynx --dump --nolist --assume-charset=UTF-8 --display-charset=UTF-8 "$html" > "$txt"
		
		#Compter le nombre d'occurrences de $mot
		#on adapte le nom de la commande en fonction de si on est sur mac ou linux
		
		if command -v ggrep > /dev/null; then
    		compte=$(cat "$txt" | ggrep -Poi "${motif}" | wc -l)
		else
    		compte=$(cat "$txt" | grep -Poi "${motif}" | wc -l)
    	fi 

		#Extraire les contextes
		if command -v ggrep > /dev/null; then
    		cat "$txt" | ggrep -P -i -A 1 -B 1 "${motif}" > "$context"
		else
    		cat "$txt" | grep -P -i -A 1 -B 1 "${motif}" > "$context"
    	fi 

	else 
		# on passe l'url si elle ne fonctionne pas, si le code n'est pas égale à 200
		continue
  	fi
	
########## Concordancier #################################################################

	# Créer un tableau pour stocker les lignes du concordancier
	concordance=()

	# Parcourir le fichier $context
	while read -r ligne; do
   	 	# Recherche du mot cible dans la ligne
    		#ATTENION ne pas mettre $motif entre guillemets car la regex ne fonctionnera pas dans une condition if [[..]]
        	if [[ $ligne =~ (.*)($motif)(.*) ]]; then #on capture les contextes avec les parenthèses 
           	 	contexte_gauche=${BASH_REMATCH[1]} #on extrait le contexte gauche (1ere parenthèse)
           	 	cible=${BASH_REMATCH[2]}
            	contexte_droit=${BASH_REMATCH[3]} #on extrait le contexte droit (3eme parenthèse)
           	 	concordance+=("$contexte_gauche;$cible;$contexte_droit") #on ajoute une nouvelle entrée au tableau séparé par des ;
        	fi
	done < "$context"

	# Rediriger la sortie vers le fichier html $concord
	
    echo "<html><head><title>Concordancier</title></head><body>" > "$concord"
    echo "<table border='1'><tr><th>Contexte Gauche</th><th>Mot Cible</th><th>Contexte Droit</th></tr>" >> "$concord"

    for ligne in "${concordance[@]}"; do #on itère sur chaque élément du tableau
        IFS=';' read -r -a elements <<< "$ligne" #on définit le séparateur comme un ; pour la lecture
        # -r : Disable backslashes to escape characters
        # -a : Instead of using individual variables to store a string, the -a option saves the input in an array
        # Retrieve the array elements with their index ${array[0]} 
        echo "<tr><td>${elements[0]}</td><td>${elements[1]}</td><td>${elements[2]}</td></tr>" >> "$concord" #on crée une entrée du tableau html
    done

    echo "</table></body></html>" >> "$concord"

##########################################################################################

	#Ecrire une ligne du tableau HTML
	echo "        <tr>
            <td>$N</td>
            <td><a href=$line>$line</a></td>
            <td>$code</td>
            <td>$encodage</td>
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
