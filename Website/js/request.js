
$('#requestb').click(function () {
  //alert("clicked")
  subscribeToRequests()
});

function getSubChannel() {
  var configObject = Parse.Object.extend("Config");
  var query = new Parse.Query(configObject);
  query.equalTo("key", "RequestChannel");
  query.find({
    success: function(results) {
      // Do something with the returned Parse.Object values
      reqChannel = results[0].get('val');
      alert("subscribing");
      alert(pb);
      try {
        pb.subscribe({
          channel: reqChannel,
          message: function(m){onNewRequest(m)},
          error: function (error) {
            // Handle error here
            alert(JSON.stringify(error));
          }
        });
      } catch (err) {
        alert("TODO: not subscribed to req channel")
      }
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

function subscribeToRequests() {
  getSubChannel();
}

function onNewRequest(m) {
  alert(m)
}

function getAvailableRequests() {
  var openRequests = Parse.Object.extend("Request");
  var query = new Parse.Query(openRequests);
  query.equalTo("taken", 0);
  query.find({
    success: function(results) {
      alert("Successfully retrieved " + results.length + " scores.");
      // Do something with the returned Parse.Object values
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

function getMyRequests() {
  var openRequests = Parse.Object.extend("Request");
  var query = new Parse.Query(openRequests);
  query.equalTo("taken", 0);
  query.find({
    success: function(results) {
      alert("Successfully retrieved " + results.length + " scores.");
      // Do something with the returned Parse.Object values
    },
    error: function(error) {
      alert("Error: " + error.code + " " + error.message);
    }
  });
}

function takeRequest(requestObject) {
  var currentUser = Parse.User.current();
  if (currentUser) {
      var objectID = requestObject.id;
      requestObject.increment("taken");
      requestObject.save(null, {
        success: function(reqObject) {
          // Execute any logic that should take place after the object is saved.
          alert('New object saved with taken: ' + reqObject.get("taken"));
        },
        error: function(gameScore, error) {
          // Execute any logic that should take place if the save fails.
          // error is a Parse.Error with an error code and message.
          alert('Failed to create new object, with error code: ' + error.message);
        }
      });
  } else {
      alert("TODO: handle not being logged in");
  }
}
