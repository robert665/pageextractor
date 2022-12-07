const eventList = [];
var onHomePage = true;

fetchEvents();

function fetchEvents() {
  fetch ("/events")
  .then (function (r) {
    return r.text();
  })
  .then (function (r) {
    return JSON.parse(r);
  })
  .then (function (r) {
    console.log(r.length)
    for(var i = 0; i < r.length; i++) {
      $("#eventarea").append(
        "<div class='event'><p class='date'>" + r[i].date +"</p><p id='int"+ i +"' class='interested' onclick='saveEvent(this)'>hinzufügen</p>" +
        "<h2 class='eventname'><a href=" +r[i].link + ">" + r[i].event +"</a></h2>" +
        "<div class='eventinside'>" +
        "<p class='location'>Loaction: " + r[i].location +"</p>" +   
        "<p class='info-text'>"+ r[i].text +"</p>" +   
        "</div></div>"    
        );
    }
  });
}

function saveEvent(element) {
  console.log($(element).attr('id'));
  var parent =    $(element).parent();
  var date =      $(parent).find(".date").text();
  var eventname = $(parent).find(".eventname").text(); 
  var link =      $(parent).find(".eventname").children().first().attr('href');
  var location =  $(parent).find(".location").text();
  var text =      $(parent).find(".info-text").text();
  /*
  console.log(date);console.log(link);console.log(eventname);console.log(location);console.log(text);
  */
  var jsonString = jsonBody(date, link, location, eventname, text);

  fetch("/save", {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: jsonString
  });
}

function jsonBody(date, link, location, event, eventText ) {
  var jsonString;
  jsonString = '{"link":"'+ link +'","event":"'+ event +'", "text":"'+ eventText +'","date":"'+ date +'","location":"'+ location +'"}'; 
  console.log(JSON.parse(jsonString)); 
  return jsonString;                                  
}

function toggleSite() {
  if(onHomePage == true) {
    fetchSavedEvents();
    onHomePage = false;
  } else {
    $("#eventarea").empty();
    fetchEvents();
    $("#saved-events").attr("src", "./img/spotlight_icon2.png" );
    onHomePage = true;
  }
}

function fetchSavedEvents() {
  fetch("/savedEvents")
    .then (function (r) {
      return r.text();
    })
    .then (function (r) {
      return JSON.parse(r);
    })
    .then(function (r) {
      $("#eventarea").empty();
      $("#saved-events").attr("src", "./img/spotlight_icon_door2.png" );
      console.log(r.length);
      for(var i = 0; i < r.length; i++) {
        $("#eventarea").append(
          "<div class='event'><p class='date'>" + r[i].date +"</p><p id='int"+ i +"' class='interested' onclick='deleteEvent(this)'>löschen</p>" +
          "<h2 class='eventname'><a href=" +r[i].link + ">" + r[i].event +"</a></h2>" +
          "<div class='eventinside'>" +
          "<p class='location'>Loaction: " + r[i].location +"</p>" +   
          "<p class='info-text'>"+ r[i].text +"</p>" +   
          "</div></div>"    
          );
      }
    });
}

function deleteEvent(element) {
  var parent =    $(element).parent();
  var eventname = $(parent).find(".eventname").text();
  jsonString = '{"name":"' + eventname + '"}';
  console.log(JSON.parse(jsonString));
  fetch("/removeEvent/" + eventname, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: jsonString
  });
  fetchSavedEvents();
}