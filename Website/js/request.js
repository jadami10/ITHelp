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
      try {
        pb.subscribe({
          channel: reqChannel,
          message: function(m){onNewRequest(m)},
          error: function (error) {
            // Handle error here
            alert(JSON.stringify(error));
          }
        });
        console.log("should be subscribed");
      } catch (err) {
        alert("TODO: not subscribed to req channel")
      }
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
  alert(m)
  // call Hannah's function to add to webpage
}

// returns all available requets
function getAvailableRequests() {
  var openRequests = Parse.Object.extend("Request");
  var query = new Parse.Query(openRequests);
  query.equalTo("taken", 0);
  query.find({
    success: function(results) {
      alert("Successfully retrieved " + results.length + " requests.");
      // Do something with the returned Parse.Object values
      if (results.length > 0) {
        testObject = results[0];
      }
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

// returns all of your requests
function getMyRequests() {
  var openRequests = Parse.Object.extend("Request");
  var currentUser = Parse.User.current();
  var query = new Parse.Query(openRequests);
  query.equalTo("taken", 0);
  query.matchesKeyInQuery("helper", "objectId", currentUser);
  query.find({
    success: function(results) {
      console.log("Successfully retrieved " + results.length + " scores.");
      // Do something with the returned Parse.Object values
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

// take a request
function takeRequest(requestObject) {
  requestObject = testObject;
  var currentUser = Parse.User.current();
  if (currentUser) {
      var objectID = requestObject.id;
      requestObject.increment("taken");
      requestObject.save(null, {
        success: function(reqObject) {
          // Execute any logic that should take place after the object is saved.
          var takenNum = reqObject.get("taken");
          if (takenNum == 1) {
            console.log("grabbed request!");
          } else {
            console.log("someone else grabbed the request");
          }
        },
        error: function(reqObject, error) {
          // Execute any logic that should take place if the save fails.
          // error is a Parse.Error with an error code and message.
          alert('Failed to create new object, with error code: ' + error.message);
        }
      });
  } else {
      alert("TODO: handle not being logged in");
  }
}
