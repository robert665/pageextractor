#!/bin/bash
#-----------------------------------------
#	      Autor: Robert Eckstein
#   Matrikelnummner: 3041442
#             Zweck: Läd zbau Seite herrunter und speichert Veranstaltungen in JSONS
#	Erfordelich: wget, jq
#-----------------------------------------

# Block 1
# speichert die Html der Zbau Seite und erstellt Zielordner falls nötig
# Befehl sucht nur die Links der Veranstaltungen aus der Html heraus
# schneidet die Ausgaben so ab, dass Datum/Location/Veranstaltung übrig bleiben
# überreste anderer Links werden entfernt, sodass nur die Veranstaltungen übrig bleiben
# speichert diese in die Datei events.txt

#Block 2
# fügt am Anfang der Zeile den Anfang der Z-bau url hinzu um dadurch links zu erhalten
# speichert diese in die eventlinks.txt

#Block 3
# filtert alle Veranstaltungstexte aus dem Programm heraus und trennt sie mit "DELIMTER"
# löscht alle "\n" => alles steht auf einer Zeile
# fügt "\n" anstatt der DELIMTER ein => jeder Text steht jetzt in seiner eigenen Zeile
# löscht alle " heraus um später keine probleme for die JSON Formatierung zu verursachen
# speichert diese in die datei res/eventtexte.txt

#Block 4
# filtert alle Veranstaltungstitel aus dem Programm heraus und trennt sie mit "DELIMITER"
# löscht alle "\n" => alles auf einer Zeile
# fügt "\n" anstatt der DELIMITER ein => jeder Titel steht jetzt in seiner eigenen Zeile
# ersetzt alle ">" durch ":"
# fügt in der ersten Zeile ein ":" ein
# extrahiert das Feld mit dem Titel (4. Feld)
# löscht alle "<" aus den Titeln
# speichert diese in res/titel.txt

#Block 5
# nimmt alle lines die zusammengehören und speichert diese in ein gültiges JSON Format ab (jq erforderlich)
# zählt lines von events um die Anzahl von events zu erhalten
# nimmt n-te zeile und speichert Inhalt in eine variable
# variablen werden dann in einen string im JSON Format eingefügt
# jq überprüft auf gültiges json-format, asnchließend gespeichert in res/json

RED='\033[0;31m'
YELLOW='\033[0;33m'
color_off='\033[0m'

while [[ "${1-}" =~ ^- ]]; do
	case "$1" in
		-v | --verbose ) verbose=1; echo "Verbose Mode on" ;;
		-d | --data ) data=1; echo "all fetched data will be printed on terminal" ;;
		-h | --help ) echo -e "This script downloads the content of the website www.zbau.com and stores it events in JSON-files.\nThe files will be stored in a folder res and also in the folder res/jsons.\nThe folders will be created when they are missing.\nOptions:\n	-h | --help : help insctructions\n	-v | --verbose : script will print out steps on terminal \n	-d | --data : script will print out all fetched data on terminal"; exit 0;;
		--) shift ; break ;;
		*) echo "Invalid option '$1'" >&2 ; exit 1 ;;
	esac
	shift
done

function log () {
    if [[ $verbose -eq 1 ]]; then
        echo -e "$@"
    fi
}

#Block 1
log --------------trying to download the webpage Z-Bau.com--------------------
if [[ $verbose -eq 1 ]]; then
	wget www.z-bau.com/programm
else 
	wget -q www.z-bau.com/programm
fi
exit_code=$?
if [ $exit_code -ne 0 ]; then
	echo -e "${RED}Wget could not reach for www.z-bau.com/programm${color_off}"
	exit 1
fi
if [ ! -d "res" ]
then
    echo -e "${YELLOW}Folder res does not exist${color_off}"
    mkdir ./res
    echo "Folder res created"
else
    log "Folder res exists"
fi
mv programm res/
grep data-url=\"https://z-bau.com/programm res/programm | cut -d "/" --fields 5-7 | grep -v \" > res/events.txt
if [[ $data -eq 1 ]]; then
	echo ---------------Events-----------------------------------------------------
	cat res/events.txt
fi
#Block 2
sed 's/^/https:\/\/z-bau.com\/programm\//' res/events.txt > res/eventlinks.txt
if [[ $data -eq 1 ]]; then
	echo ---------------Event Links------------------------------------------------
	cat res/eventlinks.txt
fi
#Block 3
sed -n '/event__info-text/,/div/{s/div/DELIMITER/;/event__info-text/d;p}' res/programm | tr -d '\n' | sed 's/DELIMITER/\n/g' | tr -d '"' > res/oneliners.txt
if [[ $data -eq 1 ]]; then
	echo ---------------Event Texts------------------------------------------------
	cat res/oneliners.txt
fi
#Block 4
sed -n '/event__main-title/,/\/span/{s/\/span/DELIMITER/;/\/span/d;p}' res/programm | tr -d '\n' | sed 's/DELIMITER/\n/g' | tr '>' ':' |sed -e 1's/.*/: &/'  | cut -d : --field 4 | tr -d  "<" > res/titel.txt
if [[ $data -eq 1 ]]; then
	echo ---------------Event Titles-----------------------------------------------
	cat res/titel.txt
fi
#Block 5
lines=$(wc -l < res/events.txt)
log "$lines entries registered"
digit1=${lines:0:1}
digit2=${lines:1:2}
if [ ! -d "res/jsons" ]
then
    echo -e "${YELLOW}Folder res/jsons does not exist${color_off}"
    mkdir ./res/jsons
    echo "Folder res/jsons created"
else
    log "Folder res/jsons exists"
fi
i=1
a=0
while [ $a -le $digit1 ]; do

	b=0
	if [ $a -lt $digit1 ]; then
		
		while [ $b -le 9 ]; do
		        eventline=$(sed -n "$i p" < res/events.txt)
			date=$(echo $eventline | cut -d "/" --field 1)
			location=$(echo $eventline |cut -d "/" --field 2)
			event=$(sed -n "$i p" < res/titel.txt)
			link=$(sed -n "$i p" < res/eventlinks.txt)
			text=$(sed -n "$i p" < res/oneliners.txt)
			
			JSON='{"link":"'"$link"'","event":"'"$event"'","text":"'"$text"'","date":"'"$date"'","location":"'"$location"'"}'
			echo $JSON | jq > res/jsons/"$a$b"object.json
			exit_code=$?
			if [ $exit_code -ne 0 ]; then
				echo -e "${YELLOW}jq could not construct JSON $i ${color_off}"
			else
				log "json $i created"
			fi
			let i=i+1
			let b=b+1
		done
	else
		
		while [ $b -lt $digit2 ]; do
		        eventline=$(sed -n "$i p" < res/events.txt)
			date=$(echo $eventline | cut -d "/" --field 1)
			location=$(echo $eventline |cut -d "/" --field 2)
			event=$(echo $eventline |cut -d "/" --field 3)
			link=$(sed -n "$i p" < res/eventlinks.txt)
			text=$(sed -n "$i p" < res/oneliners.txt)
			
			JSON='{"link":"'"$link"'","event":"'"$event"'","text":"'"$text"'","date":"'"$date"'","location":"'"$location"'"}'
			echo $JSON | jq > res/jsons/"$a$b"object.json
			exit_code=$?
			if [ $exit_code -ne 0 ]; then
				echo -e "${YELLOW}jq could not construct JSON $i ${color_off}"
			else
				log "json $i created"
			fi
			let i=i+1
			let b=b+1
		done
	fi	
	let a=a+1
done
exit 0
