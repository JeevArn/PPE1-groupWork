#!/usr/bin/env bash

./programmes/make_itrameur_corpus.sh dumps-text contextes FR
./programmes/make_itrameur_corpus.sh dumps-text contextes EN
./programmes/make_itrameur_corpus.sh dumps-text contextes KR

fullcontext="itrameur/contexte.txt"
for fichier in itrameur/contexte*.txt; do
	copie=$(cat "$fichier")
	echo "$copie" >> "$fullcontext"
done

# Attention supprimer tous les fichiers du dossier itrameur avant de relancer le script