#!/usr/bin/env bash

./programmes/script.sh URLs/FR.txt
./programmes/script.sh URLs/EN.txt
./programmes/script.sh URLs/KR.txt

# Attention suppression de tous les fichiers du dossier itrameur
rm itrameur/*

./programmes/make_itrameur_corpus.sh dumps-text contextes FR
./programmes/make_itrameur_corpus.sh dumps-text contextes EN
./programmes/make_itrameur_corpus.sh dumps-text contextes KR

fullcontext="itrameur/contexte.txt"
for fichier in itrameur/contexte*.txt; do
	copie=$(cat "$fichier")
	echo "$copie" >> "$fullcontext"
done
