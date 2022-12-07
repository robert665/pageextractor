#!/bin/bash
#läd zbau seite runter und gibt veranstaltungen aus (wget erforderlich)
# Block 1
# Befehl sucht nur die links der veranstaltungen aus der html heraus
# schneidet die Ausgaben so ab, dass Datum/Location/Veranstaltung übrig bleiben
# überreste anderer Links werden Entfernt, sodass nur die Veranstaltungen übrig bleiben
# speichert diese in die datei events.txt

#Block 2
# fügt am anfang der zeile den Anfang der Z-bau url hinzu um dadurch links zu erhalten
# speichert diese in die eventlinks.txt

#Block 3
# filtert alle Veranstaltungstexte aus dem programm heraus und trennt sie mit "DELIMTER"
# löscht alle "\n" => alles steht auf einer Zeile
# fügt "\n" anstatt der DELIMTER ein => jeder Text steht jetzt in seiner eigenen Zeile
# löscht alle " heraus um später keine probleme for die JSON formatirung zu verursachen
# speichert diese in die datei res/eventtexte.txt

#Block 4
# filtert alle Veranstaltungstitel aus dem programm heraus und trennt sie mit "DELIMITER"
# löscht alle "\n" => alles auf einer Zeile
# fügt "\n" anstatt der DELIMITER ein => jeder Titel steht jetzt in seiner eigenen Zeile
# ersetzt alle ">" durch ":"
# fügt in der ersten Zeile ein ":" ein
# extrahiert das Feld mit dem Titel (4. Feld)
# löscht alle "<" aus den titeln
# speichert diese in res/titel.txt

#Block 5
# nimmt alle lines die zusammengehören und speichert diese in ein gültiges json format ab (jq erforderlich)
# zählt lines von events um die anzahl von events zu erhalten
# nimmt n-te zeile und speichert inhalt in eine variable
# variablen werden dann in einen string im json-format eingefügt
# jq überprüft auf gültiges json-format, asnchließend gespeichert in res/json


#Block 1
echo --------------trying to download the webpage Z-Bau.com--------------------
wget www.z-bau.com/programm
mv programm res/
grep data-url=\"https://z-bau.com/programm res/programm | cut -d "/" --fields 5-7 | grep -v \" > res/events.txt
echo --------------printing Events--------------------------------------------
cat res/events.txt
#Block 2
echo -------------- Event Links---------------------------------------
sed 's/^/https:\/\/z-bau.com\/programm\//' res/events.txt > res/eventlinks.txt
cat res/eventlinks.txt
#Block 3
sed -n '/event__info-text/,/div/{s/div/DELIMITER/;/event__info-text/d;p}' res/programm | tr -d '\n' | sed 's/DELIMITER/\n/g' | tr -d '"' > res/oneliners.txt
#Block 4
sed -n '/event__main-title/,/\/span/{s/\/span/DELIMITER/;/\/span/d;p}' res/programm | tr -d '\n' | sed 's/DELIMITER/\n/g' | tr '>' ':' |sed -e 1's/.*/: &/'  | cut -d : --field 4 | tr -d  "<" > res/titel.txt
#Block 5
lines=$(wc -l < res/events.txt)
echo $lines
digit1=${lines:0:1}
digit2=${lines:1:2}
echo $digit1
echo $digit2
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
			echo $i
			
			JSON='{"link":"'"$link"'","event":"'"$event"'","text":"'"$text"'","date":"'"$date"'","location":"'"$location"'"}'
			echo $JSON | jq > res/jsons/"$a$b"object.json
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
			echo $i
			
			JSON='{"link":"'"$link"'","event":"'"$event"'","text":"'"$text"'","date":"'"$date"'","location":"'"$location"'"}'
			echo $JSON | jq > res/jsons/"$a$b"object.json
			let i=i+1
			let b=b+1
		done
	fi	
	let a=a+1
done


exit 0
