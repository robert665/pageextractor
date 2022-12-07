# pageextractor

"Spotlight" a webapp by Robert Eckstein | still in development 7.12.2022

The Pageextractor "Spotlight" is a Webapp which is supposed to fetch Data from different Websites to process them and afterwards display them.
The main purpose is to display upcoming events and save them to a "interested-list".  
Currently the only website which is searched is "www.z-bau.com", but more websites will be added in the future.

---------------
Disclaimer:

This Project uses a Node Express Server to provide the Data to the client. 
To fetch the Data a bash script is used. <br>
Right now the bash script is NOT automatically started and NOT tested on Windows. <br>
For testing purposes the needed Data is already present and does not has to be fetched by the bash script.
If you want to use the script the commands wget and jq should be installed.
---------------

Process Flow:

(0. optional): 
First start the bash script manually over the terminal.
The bash script downloads the html page from "www.z-bau.com" and stores it in a file called "programm" in res directory.
After that information about the upcoming events are gathered and stored into files:

-the links of every event -> eventlinks.txt <br>
-the date, location and name -> events.txt <br>
-the discription of the event -> oneliners.txt <br>
-the titel of the event -> titel.txt <br>

At last the script reads every of the above files line by line to constructs a json in the following pattern:

{
  "link": "https://z-bau.com/programm/2022-11-27/asphaltflache-schallschutzwand/ak-rollgarten", <br>
  "event": "AK Rollgarten", <br>
  "text": "> Wir freuen uns auf euch! 🛹🛼✨🎶 </", <br>
  "date": "2022-11-27", <br>
  "location": "asphaltflache-schallschutzwand" <br>
}

Starting with a naming from "00object.json" to possibly "99object.json" and stores them in the folder res/jsons
This means right now the upper border for jsons is limited to 99 objects.

1. Starting the server
Start the Express server by running the command "node server.js" in the terminal in the pageextractor directory.
If the start was successfull "server listening on 8080" should appear in the terminal.
When the server has started it reads in all events that are stored in res/jsons and also all files (if existing) from res/savedEvents.
The files will be parsed to json and saved dynamically and separately in the arrays "eventList" and "savedEventList" 

2. Visiting the Website
Type "localhost:8080" in your browser searchfield to open the Webapp.
By sending a GET request to the server the index.html is delivered and the indexscript.js will be executed.
The indexscript.js innitially calls the method fetchEvents() which sends a fetch GET request to recieve all data which is stored in 
"eventList" on the server. Afterwards the data is parsed to json and inserted in various html tags to display it to the user.

3. Switching to the "interested-list"
The upper right icon can be used to switch the view from all current events to the events the user has saved.
This is provoked by calling the fetchSavedEvents() which does exactly the same as the fetchEvents() but referencing to "savedEventList".
Additionally it clears the screen from previous events and displays the fetched Data.
The same Button can be used to return to the initial state of the site.

Every div with the class "event" has a button called "hinzufügen" to save it on serversite at the directory res/savedEvents as an actual file.
This ensures that saved events will not be lost when the server has been restarted.

---------------
The next step is to get the "löschen" button working but i have not figured a way out to compare the data from the client with the filedata at serversite.
when this is completed further websites will be added.









