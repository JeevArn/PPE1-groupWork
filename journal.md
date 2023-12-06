# Journal de Groupe

# Séance 9
## 22 novembre 2023 
           
Travail de groupe :
choix du mot : "héritage"
langues : EN, FR, KR
(changement de langue : anglais à la place du thai)

problèmes rencontrés :
- le concordancier ne fonctionne pas
- certains charset ne s'affichent pas dans le tableau
- certains contextes ne sont pas extrait alors que le mot est bien présent dans la page
- certains sites affichent le code 000
- il y a des problèmes d'encodage en coréen

lien du dépôt github commun au groupe : https://github.com/JeevArn/PPE1-groupWork
lien du site créé : https://jeevarn.github.io/PPE1-groupWork/index.html

# Séance 10
## 20 novembre 2023 

correction Ex2 :
lynx -dump -nolist aspiration.html/fr-1.html > dump-text/fr-1.txt
-> condition : uniquement sur les liens avec un code http 200

correction Ex3 :
- c : compter le nombre d'occurrences
=> Attention compte le nombre de ligne
grep -c "motif" cheminfichier/nomfichier.txt

grep -i -o pour compter  et | wc -l

pour les contextes :
grep -i -C 3 "héritage"
il faudra accepter héritage avec un s

concordancier :
sed 
ggrep -o -i -P "(\w+\W){0,5}héritages?(\W\w+){0,5}" $txt | less

on doit utiliser iconv pour les textes qui ne sont pas en utf8

Difficultés rencontrées pour les exercices sur iTrameur :
- ex2 : faut-il prendre en argument le dossier URLs ou bien le dossier dumps-text ?
ce qu'on a fait : dumps-text en argument

- ex3 : faut-il avoir un fichier contexte pour chaque langue dans le dossier itrameur 
ou un seul fichier contexte qui contient toutes les langues ?
ce qu'on a fait : les deux

Autre pb lorsqu'on exécute notre script : 
erreur tr: Illegal byte sequence
cependant les fichiers sont quand même bien créés dans le dossier itrameur
Aussi les balises dans les fichiers ne sont pas classées dans l'ordre croissant

- ex4 et 5 : nous n'avons pas bien compris ce qu'il fallait rendre sur github
   
![<# alt text #>](../../../../Capture%20d%E2%80%99e%CC%81cran%202023-12-04%20a%CC%80%2018.02.25.png "Screenshot")

Les changements dans le script principal :
* les problèmes de contextes vides et de concordancier qui ne fonctionnaient pas ont été réglés dans les 3 langues
* nous avons opter pour une autre méthode d'extraction du charset avec BASH REMATCH qui semble mieux fonctionner que l'ancienne
* de même pour le concordancier nous avons utiliser BASH REMATCH
* on a rajouté une variable $motif pour mettre des regex à la place de la variable $mot qui ne reconnaissait pas les variations
* pour le coréen certains fichiers html ne se convertissent pas correctement en utf-8
* ajout du script main

# Séance 11
## 6 décembre 2023 


                
        
                
                
                
                                                