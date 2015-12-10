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

Parse.Cloud.afterDelete("Request", function(request) {
  var reqID = request.object.id;
  var requester = request.object.get("requester");
  publishRequest(requester, reqID, "RequestDeleted", pubnub_ios);
  publishRequest(req_channel, reqID, "TicketDeleted", pubnub_web);
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

function handleRequest(request) {

  var curUser = request.user;
  var reqID = request.object.id;
  var taken = request.object.get("taken");
  var taker = Parse.User.current();
  var helper = request.object.get("helper");
  var requester = request.object.get("requester");
  var requesterPointer = request.object.get("requesterPointer");
  var requesterSolved = request.object.get("requesterSolved");
  var helperSolved = request.object.get("helperSolved");
  var numHelpers = request.object.get("allHelpers").length;

  if (taken == 0) {
    // not taken
    if (helper == null) {
      // no current helper
      if (numHelpers > 0) {
        // ticket was given up on
        console.log("republishing request");
        publishRequest(requester, reqID, "RequestReleased", pubnub_ios);
        publishRequest(req_channel, reqID, "TicketReadded", pubnub_web);
      } else if (requesterSolved == -1 && helperSolved == -1) {
        // new ticket
        console.log("publishing new request");
        publishRequest(requester, reqID, "RequestAdded", pubnub_ios);
        publishRequest(req_channel, reqID, "TicketAdded", pubnub_web);
      } else {
        unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
      }
    } else {
      // there is a helper
      if (requesterSolved == -1 && helperSolved == -1) {
        // someone just took ticket
        console.log("Request taken. notify app!");
        publishRequest(requester, reqID, "RequestTaken", pubnub_ios);
        publishRequest(req_channel, reqID, "TicketTaken", pubnub_web);
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
          console.log("someone taking request");
          request.object.set("helper", taker);
          request.object.addUnique("allHelpers", taker);
          request.object.save();
          publishRequest(requester, reqID, "RequestTaken", pubnub_ios);
          publishRequest(req_channel, reqID, "TicketTaken", pubnub_web);
          publishRequest(taker.id, reqID, "TicketGranted", pubnub_web);
          sendPush(requesterPointer, reqID);
        } else {
          unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
        }
      } else {
        // there is a current helper
        if (requesterSolved == 1 && helperSolved != 1 ) {
          // requester marked it as solved
          publishRequest(helper.id, reqID, "RequestSolved", pubnub_web);
          publishRequest(requester, reqID, "TicketSolved", pubnub_ios);
        } else if (helperSolved == 1 && requesterSolved == -1) {
          // helper marked as solved
          publishRequest(requester, reqID, "RequestSolved", pubnub_ios);
        } else if (helperSolved == 1 && requesterSolved != 1) {
          // requester declined solution
          publishRequest(requester, reqID, "SolutionDeclined", pubnub_ios);
        } else if (helperSolved == 1 && requesterSolved == 1) {
          // requester declined solution
          publishRequest(helper.id, reqID, "TicketSolved", pubnub_web);
        } else {
          unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
        }
      }
  } else {
    unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved);
  }

}

function unhandledRequest(curUser, taken, helper, requesterSolved, helperSolved) {
  console.log("Unhandled request | curUser: " + curUser + " taken: " + taken +
  " helper: " + helper + " reqSolved: " + requesterSolved + " helpSolved: " + helperSolved);
}

function sendPush(user, reqID) {
  var installation = Parse.Object.extend("Installation");
  var installQuery = new Parse.Query(installation);
  installQuery.equalTo("user", user);
  Parse.Push.send({
    where: installQuery, // Set our Installation query
    data: {
      alert: "Someone is here to help you with your issue!",
      viewIdentifier: "testidentifier",
      ticketObjectId: reqID
    }
  }, {
    success: function() {
        // Push was successful
        console.log("push notification sent to: " + user.id)
      },
      error: function(error) {
        throw "Got an error " + error.code + " : " + error.message;
      }
  });
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
      installId = results.object.get("installationId");
      console.log("this is the INSTALL ID" + installId);
      var pushQuery = new Parse.Query(Parse.Installation);
      pushQuery.equalTo('installationId', installId);
      Parse.Push.send({
        where: pushQuery, // Set our Installation query
        data: {
          alert: "Someone is here to help you with your issue, " + user,
          viewIdentifier: "testidentifier",
          ticketObjectId: "testobjectid"
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
