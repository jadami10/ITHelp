import pb from '../utils/pubnub';

var user = {};
var flg = {};
var reqChannel;
var messageChannels = {};
// var availableRequests = [];
var myRequests = [];
var testObject;

export function subscribeToChat(requestObject, onMessage) {
  try {
    subscribeToChannel(requestObject.id, onMessage);
  } catch(err) {
    console.log("Chat: Could not subscribe: " + err);
  }
}

// use this to subscribe to request
// Gets the subscription channel and hooks to the 'onNewRequest'
// function to handle live requests
export function subscribeToRequests(onNewRequest) {
  var configObject = Parse.Object.extend("Config");
  var query = new Parse.Query(configObject);
  query.equalTo("key", "RequestChannel");
  query.find({
    success: function(results) {
      // Do something with the returned Parse.Object values
      reqChannel = results[0].get('val');
      try {
        subscribeToChannel(reqChannel, onNewRequest);
      } catch(err) {
        console.log("Requests: Could not subscribe: " + err);
      }
    },
    error: function(error) {
      console.log("Error: " + error.code + " " + error.message);
    }
  });
}

export function subscribeToUser(reqChannel, onMessage) {
  try {
    subscribeToChannel(reqChannel, onMessage);
  } catch(err) {
    console.log("User: Could not subscribe: " + err);
  }
}

export function subscribeToChannel(reqChannel, onMessage) {
  try {
    pb.subscribe({
      channel: reqChannel,
      message: function(m){onMessage(m)},
      connect: function() {
        console.log("should be subscribed");
      },
      error: function (error) {
        console.log(JSON.stringify(error));
      }
    });
  } catch(err) {
    console.log("Could not subscribe: " + err);
  }
}

// take a request
export function takeRequest(requestObject) {
  var currentUser = Parse.User.current();

  if (currentUser) {
      console.log("Get ticket:", requestObject);

      var objectID = requestObject.id;
      requestObject.increment("taken");
      requestObject.save(null, {
        success: function(reqObject) {
          // check that it's actually assigned to you
        },
        error: function(reqObject, error) {
          console.log("Failed to create new object with error: " + error.code + " " + error.message);
        }
      });
  } else {
      console.log("TODO: handle not being logged in");
  }
}
