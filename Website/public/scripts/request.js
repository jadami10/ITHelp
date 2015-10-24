var testObject;

$('#requestb').click(function () {
  //alert("clicked")
  subscribeToRequests()
});

// Gets the subscription channel and hooks to the 'onNewRequest'
// function to handle live requests
function getSubChannel() {
  var configObject = Parse.Object.extend("Config");
  var query = new Parse.Query(configObject);
  query.equalTo("key", "RequestChannel");
  query.find({
    success: function(results) {
      // Do something with the returned Parse.Object values
      reqChannel = results[0].get('val');
      console.log("subscribing");
      subscribeToChannel(reqChannel, onNewRequest);
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

// use this to subscribe to request
function subscribeToRequests() {
  getSubChannel();
}

// TODO: add code to handle new requests
function onNewRequest(m) {
  // alert("new request");
  console.log("new request!!", m);
  updateTicket();
}

// returns all available requets
function getAvailableRequests() {
  var openRequests = Parse.Object.extend("Request");
  var query = new Parse.Query(openRequests);
  query.equalTo("taken", 0);
  query.find({
    success: function(results) {
      console.log("Successfully retrieved " + results.length + " requests.");
      // Do something with the returned Parse.Object values
      availableRequests = results;
      console.log(availableRequests);
      // TODO: return all available requests
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

// returns all of your requests
function getMyRequests(doSubscribe) {
  var openRequests = Parse.Object.extend("Request");
  var currentUser = Parse.User.current();
  var query = new Parse.Query(openRequests);
  query.matchesKeyInQuery("helper", "objectId", currentUser);
  query.find({
    success: function(results) {
      myRequests = results;
      if (results.length > 0) {
        for (var i = 0; i < results.length; i++) {
          var result = results[i];
          if (doSubscribe) {
            subscribeToChat(result);
          }
        }
      }
      console.log("Successfully retrieved " + results.length + " scores.");
      // TODO: return my requests
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

// check if request is yours
function checkMyRequest(reqObject, doSubscribe) {
  var openRequests = Parse.Object.extend("Request");
  var currentUser = Parse.User.current();
  var query = new Parse.Query(openRequests);
  query.matchesKeyInQuery("helper", "objectId", currentUser);
  query.equalTo("objectId", reqObject.id);
  query.find({
    success: function(results) {
      if (results.length > 0) {
        console.log(reqObject + " was mine");
        if (doSubscribe) {
          subscribeToChat(results[0]);
          myRequests.push(results[0]);
        }
      } else {
        console.log("someone else grabbed the request");
        return false;
      }
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
      return false;
    }
  });
}

// take a request
function takeRequest(requestObject) {

  var currentUser = Parse.User.current();

  if (currentUser) {
      console.log("Get ticket:", requestObject);

      var objectID = requestObject.id;
      requestObject.increment("taken");
      requestObject.save(null, {
        success: function(reqObject) {
          // check that it's actually assigned to you
          // TODO: set security so not just anybody can hijack here
          checkMyRequest(reqObject, true);
        },
        error: function(reqObject, error) {
          alert("Failed to create new object with error: " + error.code + " " + error.message);
        }
      });
  } else {
      alert("TODO: handle not being logged in");
  }
}

// handle creation of new chat
function subscribeToChat(requestObject) {
  try {
    //var channel = requestObject.get("comChannel");
    var channel = requestObject.id;
    subscribeToChannel(channel, onMessage);
  } catch(err) {
    console.log("Could not subscribe: " + err);
  }

}
