import SolveTicketsBox from '../components/SolveTicketsBox';
import pb from '../utils/pubnub'

var user = {};
var flg = {};
var reqChannel;
var messageChannels = {};
// var availableRequests = [];
var myRequests = [];
var testObject;

export function subscribeToChat(requestObject) {
  try {
    //var channel = requestObject.get("comChannel");
    var channel = requestObject.id;
    subscribeToChannel(channel, onMessage);
  } catch(err) {
    console.log("Could not subscribe: " + err);
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
      subscribeToChannel(reqChannel, onNewRequest);
    },
    error: function(error) {
      console.log("Error: " + error.code + " " + error.message);
    }
  });
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
          checkMyRequest(reqObject, true);
        },
        error: function(reqObject, error) {
          console.log("Failed to create new object with error: " + error.code + " " + error.message);
        }
      });
  } else {
      console.log("TODO: handle not being logged in");
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
      console.log("Error: " + error.code + " " + error.message);
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
      console.log("Error: " + error.code + " " + error.message);
      return false;
    }
  });
}
