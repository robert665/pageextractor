const fileSystemModule = require('fs');
const port = 8080;
const express = require('express');
const path = require('path');
var bodyParser = require('body-parser');
const { exec } = require('child_process');
const app = express();

var directoryPathZbau = path.join(__dirname, 'res/jsons');
var directoryPathSaved = path.join(__dirname, 'res/savedEvents');

var eventList = [];
var savedEventList = [];

runShellScripts();

readInDirectory(directoryPathZbau, eventList);
readInDirectory(directoryPathSaved, savedEventList);


app.use(express.static('public'));
app.use(express.json());
app.use(express.urlencoded({extended:false}));

app.get('/', (req,res) => {
    res.sendFile(path.join(__dirname + "/index.html"));
});

app.get("/events",  (req, res) => {
    res.send(JSON.stringify(eventList));
    
});

app.get("/savedEvents", (req, res) => {
    res.send(JSON.stringify(savedEventList));
})

app.post("/save", (req, res) => {
    var fileExists = false;
    const eventData = req.body;
    console.log(eventData);
    console.log(req.body);
    checkMissingEventData(eventData);

    if(savedEventList[0] == "undefined") {
        savedEventList.push(eventData);
        saveEventData(eventData);
        console.log("file added")   
    } else {
        for(var i = 0; i < savedEventList.length; i++) {
            if(eventData.event == savedEventList[i].event) {
                console.log("entry already exists");
                fileExists = true
            }
        }
        if(fileExists == false) {
            saveEventData(eventData);
            console.log("file added")
        }
    } 
});

app.delete("/removeEvent/:name", (req, res) => {
    console.log(req.params);
    console.log(req.params.name);
    eventName = req.params.name;
    for(var i = 0; i < savedEventList.length; i++) {
        if(eventName == savedEventList[i].event) {
            console.log("entry exists get ready for DELETION!");
            deleteFile(i);
        }
    }

    return res.json({
        message: "delete event"
    });
});

app.listen(port , ()=>{
    console.log("server running on " + port);
});

function readInFile(text) {
    try {
        const data = fileSystemModule.readFileSync(text, 'utf8');
        //console.log(data);
        var target = data;
        return data;
      } catch (err) {
        console.error(err);
      }
}

function readInDirectory(path, list) {
    fileSystemModule.readdir(path, function (err, files) {
        if(err) {
            return console.log("unable to scan " + __dirname + " due to:" + err);
        } 
        files.forEach(function (file) {
            content = readInFile(path + "/" + file);
            list.push(JSON.parse(content));
        });
    });
}

function saveEventData (eventData) {
    savedEventList.push(eventData);
    const stringifyData = JSON.stringify(eventData);
    var index = savedEventList.length
    fileSystemModule.writeFileSync("res/savedEvents/"+ index +"savedEvent.json", stringifyData);
}

function checkMissingEventData(eventData) {
    if(eventData.link == null || eventData.event == null || eventData.text == null || eventData.date == null || eventData.location == null) {
        return res.status(401).send({error: true, msg: "Event data missing"});
    }
}

function deleteFile(num) {
    console.log(savedEventList[num]);
    console.log(num);
    savedEventList.splice(num,1);
    num += 1;
    var path = directoryPathSaved + "/" + num + "savedEvent.json";
    fileSystemModule.unlinkSync(path);
}

function runShellScripts() {
    runScript("zbaucrawler.sh -v");
}

function runScript(command) {
    var zbauScript = exec('bash ' + command,
        (error, stdout, stderr) => {
            console.log(stdout);
            console.log(stderr);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });
}

