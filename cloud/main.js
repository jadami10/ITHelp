var pubnub_web = {
  "publish_key": "pub-c-0239b592-0603-4849-9889-ce70e8d18cb7",
  "subscribe_key": "sub-c-8e935f6a-6eb4-11e5-95b8-0619f8945a4f",
  "secret_key": "sec-c-OTQyNjQzZDEtMGUzZC00OGU1LTk3OGQtMmRlNTQyY2Y2ZGNh"
};

var pubnub_ios = {
  "publish_key": "pub-c-23a2994a-72c2-43a3-a8e7-d63f3e382009",
  "subscribe_key": "sub-c-bdfa77b2-793f-11e5-a643-02ee2ddab7fe"
};
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var req_channel = "RequestChannel";

// limit number of requests
Parse.Cloud.beforeSave("Request", function(request, response) {
  if(request.master) {
    console.log("Master making request changes");
    response.success();
    return;
  }
  error = initialCheckFailed(request);
  console.log("Before_save_req_err: " + error);
  if (error != null) {
    response.error(error);
    return;
  }

  var isNew = request.object.isNew();
  var dirtyKey = request.object.dirtyKeys();
  var username = Parse.User.current().getUsername();
  var requester = request.object.get("requester");

  if (username != requester) {
    // check if someone else is trying to update ticket. return success cause it's probably the helper
    console.log(username + " trying to update a request for " + requester);
    response.success();
    return;
  } else if (!isNew) {
    // Same person trying to update ticket. Make sure it's not a helper taking their own ticket
    // Otherwise it's the user editing the ticket somehow. Probably marking it solved
    for (dk in dirtyKey) {
      if (dk == "taken") {
        response.error("Cannot take your own ticket");
        return;
      }
    }
    response.success();
    return;
  } else {
    var req = request.object;
    req.set("helperSolved", -1);
    req.set("requesterSolved", -1);
    req.set("allHelpers", []);
    response.success();
    /*
    // It's a new ticket coming in. Let's make sure they haven't passed their limit
    var openRequests = Parse.Object.extend("Request");
    var query = new Parse.Query(openRequests);
    query.equalTo("requester", username);
    query.notEqualTo("requesterSolved", 1);
    query.count({
      success: function(count) {
        // The count request succeeded. Show the count
        if (count < 5) {
          var req = request.object;
          req.set("helperSolved", -1);
          req.set("requesterSolved", -1);
          req.set("allHelpers", []);
          response.success();
        } else {
          response.error("Too many open requests");
        }
      },
      error: function(error) {
        response.error(error);
      }
    });
    */
  }
});

// publish request to pubnub after it"s added
Parse.Cloud.afterSave("Request", function(request) {
  error = initialCheckFailed(request);
  console.log("After_save_req_err: " + error);
  handleRequest(request);
  if (error != null) {
    console.log(error);
    return;
  }
});

Parse.Cloud.afterSave("Message", function(message) {

  // send to pubnub
  if (message.object.get("message") == "") {
    console.log("Ignore blank message");
    return;
  }
  var channel = message.object.get("request").id;
  sendMessage(channel, message.object);

});

//https://pubsub.pubnub.com/publish/pub-c-0239b592-0603-4849-9889-ce70e8d18cb7/sub-c-8e935f6a-6eb4-11e5-95b8-0619f8945a4f/0/RK7csydM2l/0/%7B%22sender%22%3A%22jadami10%22%2C%22message%22%3A%22test3%22%7D
// send a message to a channel
function sendMessage(channel, message) {

  var messageObject = {
    "sender":message.get("sender"),
    "message":message.get("message")
  };

  var toSend = encodeURIComponent(JSON.stringify(messageObject));

  var myUrl = "https://pubsub.pubnub.com/publish/" +
  pubnub_web.publish_key   +   "/" +
  pubnub_web.subscribe_key + "/0/" +
  channel          + "/0/" +
  toSend;

  console.log(myUrl);

  Parse.Cloud.httpRequest({
    url: myUrl,

    // SUCCESS CALLBACK
    success: function(httpResponse) {
      console.log("Message sent succefully");
      console.log(httpResponse.text);
      // httpResponse.text -> [1,"Sent","14090206970886734"]
    },

    // You should consider retrying here when things misfire
    error: function(httpResponse) {
      console.error("Request failed " + httpResponse.status);
    }
  });

  var myUrl = "https://pubsub.pubnub.com/publish/" +
  pubnub_ios.publish_key   +   "/" +
  pubnub_ios.subscribe_key + "/0/" +
  channel          + "/0/" +
  toSend;

  console.log(myUrl);

  Parse.Cloud.httpRequest({
    url: myUrl,

    // SUCCESS CALLBACK
    success: function(httpResponse) {
      console.log("Message sent succefully");
      console.log(httpResponse.text);
      // httpResponse.text -> [1,"Sent","14090206970886734"]
    },

    // You should consider retrying here when things misfire
    error: function(httpResponse) {
      console.error("Request failed " + httpResponse.status);
    }
  });
}

// publishes request to IT helpers
function publishRequest(req_channel, requestID, requestType, pubnub) {

  var messageObject = {
    "requestID": requestID,
    "requestType": requestType
  };

  var toSend = encodeURIComponent(JSON.stringify(messageObject));

  var myUrl = "https://pubsub.pubnub.com/publish/" +
  pubnub.publish_key   +   "/" +
  pubnub.subscribe_key + "/0/" +
  req_channel          + "/0/" +
  //""" + requestID + """;
  toSend;

  console.log(myUrl);
  Parse.Cloud.httpRequest({
    url: myUrl,

    // SUCCESS CALLBACK
    success: function(httpResponse) {
      console.log("success: " + httpResponse.text);
      // httpResponse.text -> [1,"Sent","14090206970886734"]
    },

    // You should consider retrying here when things misfire
    error: function(httpResponse) {
      console.error("Request failed " + httpResponse.status);
    }
  });
}

function initialCheckFailed(request) {
  if (request.master) {
    return "Master making changes.";
  }
  if (Parse.User.current() == null) {
    return "Not logged in user";
  }
  var username = Parse.User.current().getUsername();
  if (username == null) {
    return "Not logged in username";
  }
  return null;
}

function notifyUsers(request){
  console.log("notifyUsers function accessed");

  /*
  var taken = request.object.get('taken');
  var helper = request.object.get('helper');
  var requesterSolved = request.object.get('requesterSolved');
  var helperSolved = request.object.get('helperSolved');


  if (taken == 0 && helper == undefined && requesterSolved == -1 && helperSolved == -1) {
  // brand new ticket
  console.log("publishing new request");
  publishRequest(req_channel, reqID, "toWeb", pubnub_web);
} else if (taken == 1 && curUser != null && helper != null) {
  // actionable item on ticket
if (requesterSolved == 1 && helperSolved == 1) {
  console.log("Request is solved!")
  //Handle notifying app and web
  var pushQuery = new Parse.Query(Parse.Installation);
    //TODO: add device type
    pushQuery.equalTo('user', requester);
    Parse.Push.send({
      where: pushQuery, // Set our Installation query
      data: {
        alert: "Your issue has been resolved!"
      }
    }, {
      success: function() {
        // Push was successful
        console.log("succesful push")
      },
      error: function(error) {
        throw "Got an error " + error.code + " : " + error.message;
      }
    });
  }
} else if (helperSolved == 1 && requesterSolved == -1) {
console.log("Helper marked as solved. Notify user.");
var pushQuery = new Parse.Query(Parse.Installation);
    //TODO: add device type
    pushQuery.equalTo('user', requester);
    Parse.Push.send({
      where: pushQuery, // Set our Installation query
      data: {
        alert: "Your issue has been resolved!"
      }
    }, {
      success: function() {
        // Push was successful
        console.log("succesful push")
      },
      error: function(error) {
        throw "Got an error " + error.code + " : " + error.message;
      }
    });
// TODO: Handle notifying app
} else if (helperSolved == -1 && requesterSolved == -1) {
console.log("Request taken. notify app!");
publishRequest(requester, reqID, "RequestTaken", pubnub_ios);
var pushQuery = new Parse.Query(Parse.Installation);
    //TODO: add device type
    pushQuery.equalTo('user', requester);
    Parse.Push.send({
      where: pushQuery, // Set our Installation query
      data: {
        alert: helperName + " is going to help you with your issue!"
      }
    }, {
      success: function() {
        // Push was successful
        console.log("succesful push")
      },
      error: function(error) {
        throw "Got an error " + error.code + " : " + error.message;
      }
    });
} else if (helperSolved == 1 && requesterSolved == 0) {
console.log("Requester denied solution.");
// TODO: handle notifying web
}
} else if (taken == 1 && taker != null && helper == null) {
console.log("someone taking request");
request.object.set("helper", taker);
request.object.addUnique("allHelpers", taker);
request.object.save();
} else {
console.log("Something happened. notify app!");
publishRequest(requester, reqID, pubnub_ios);
}
*/
}

function handleRequest(request) {

  var curUser = request.user;
  var reqID = request.object.id;
  var taken = request.object.get("taken");
  var taker = Parse.User.current();
  var helper = request.object.get("helper");
  var requester = request.object.get("requester");
  var requesterSolved = request.object.get("requesterSolved");
  var helperSolved = request.object.get("helperSolved");

  if (taken == 0) {
    // not taken
    if (helper == null) {
      // no current helper
      if (requesterSolved == -1 && helperSolved == -1) {
        // new ticket
        console.log("publishing new request");
        publishRequest(req_channel, reqID, "toWeb", pubnub_web);
      } else {
        unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
      }
    } else {
      // there is a helper
      if (requesterSolved == -1 && helperSolved == -1) {
        // someone just took ticket
        console.log("Request taken. notify app!");
        notifyUsers(request);
        publishRequest(requester, reqID, "RequestTaken", pubnub_ios);
      } else {
        unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
      }
    }
  } else if (taken == 1) {
    // is taken or trying to be taken
      if (helper == null) {
        // there is not a current helper
        if (requesterSolved == -1 && helperSolved == -1) {
          // request being taken
          sendPush(requester);
          console.log("someone taking request");
          request.object.set("helper", taker);
          request.object.addUnique("allHelpers", taker);
          request.object.save();
          publishRequest(requester, reqID, "RequestTaken", pubnub_ios);
        } else {
          unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
        }
      } else {
        // there is a current helper
          unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
      }
  } else {
    unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
  }

}

function unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved) {
  console.log("Unhandled request | curUser: " + curUser + " taken: " + taken +
  " helper: " + helper + " reqSolved: " + requesterSolved + " helpSolved: " + helperSolved);
}

function sendPush(username) {
  getUserFromUsername(username);
}

function getUserFromUsername(username) {
  var userQuery = new Parse.Query(Parse.User);
  userQuery.equalTo("username", username)
  userQuery.first({
  success: function(object) {
    // Successfully retrieved the object.
    console.log("SUCCESSFULLY GOT OBJECT FROM USER" + object);
    getInstallationFromUser(object)
  },
  error: function(error) {
    console.log("Error: " + error.code + " " + error.message);
  }
});
}

function getInstallationFromUser(user) {
  var installation = Parse.Object.extend("Installation");
  var installQuery = new Parse.Query(installation);
  installQuery.equalTo("user", user);
  installQuery.first({
    success: function(results) {
      installId = results.get("installationId");
      console.log("this is the INSTALL ID" + installId);
      var pushQuery = new Parse.Query(Parse.Installation);
      pushQuery.equalTo('installationId', installId);
      Parse.Push.send({
        where: pushQuery, // Set our Installation query
        data: {
          alert: "Someone is here to help you with your issue, " + user
        }
      }, {
        success: function() {
            // Push was successful
            console.log("push notification sent to: " + installId)
          },
          error: function(error) {
            throw "Got an error " + error.code + " : " + error.message;
          }
      });

    }
  });
}
