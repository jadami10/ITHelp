var pubnub_web = {
  'publish_key': 'pub-c-0239b592-0603-4849-9889-ce70e8d18cb7',
  'subscribe_key': 'sub-c-8e935f6a-6eb4-11e5-95b8-0619f8945a4f',
  'secret_key': 'sec-c-OTQyNjQzZDEtMGUzZC00OGU1LTk3OGQtMmRlNTQyY2Y2ZGNh'
};

var pubnub_ios = {
  'publish_key': 'pub-c-23a2994a-72c2-43a3-a8e7-d63f3e382009',
  'subscribe_key': 'sub-c-bdfa77b2-793f-11e5-a643-02ee2ddab7fe'
};
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var req_channel = "RequestChannel";

// limit number of requests
Parse.Cloud.beforeSave("Request", function(request, response) {
  if (initalCheckFailed(request, response)) {
    return;
  }
  var openRequests = Parse.Object.extend("Request");
  var query = new Parse.Query(openRequests);

  query.equalTo("requester", username);
  //query.equalTo("taken", 0);
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
        response.error("Too many open requests")
      }
    },
    error: function(error) {
      response.error(error)
    }
  });
});

// publish request to pubnub after it's added
Parse.Cloud.afterSave("Request", function(request) {
  if (initalCheckFailed(request, null)) {
    return;
  }
  // send to pubnub
  var taker = request.user;
  var taken = request.object.get("taken");
  var helper = request.object.get("helper");
  var reqID = request.object.id;
  var requester = request.object.get("requester");
  var requesterSolved = request.object.get("requesterSolved");
  var helperSolved = request.object.get("helperSolved");
  if (taken == 0 && helper == null) {
    console.log("publishing new request");
    publishRequest(req_channel, reqID, pubnub_web);
  } else if (taken == 1 && taker != null && helper != null) {
    if (requesterSolved == 1 && helperSolved == 1) {
      console.log("Request is solved!")
      // TODO: Handle notifying app and web
    } else if (helperSolved == 1 && requesterSolved == -1) {
      console.log("Helper marked as solved. Notify user.");
      // TODO: Handle notifying app
    } else if (helperSolved == -1 && requesterSolved == -1) {
      console.log("notify app!");
      publishRequest(requester, reqID, pubnub_ios);
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
    console.log("notify app!");
    publishRequest(requester, reqID, pubnub_ios);
  }

});

Parse.Cloud.afterSave("Message", function(message) {

  // send to pubnub
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

  var myUrl = 'https://pubsub.pubnub.com/publish/' +
  pubnub_web.publish_key   +   '/' +
  pubnub_web.subscribe_key + '/0/' +
  channel          + '/0/' +
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
      console.error('Request failed ' + httpResponse.status);
    }
  });

  var myUrl = 'https://pubsub.pubnub.com/publish/' +
  pubnub_ios.publish_key   +   '/' +
  pubnub_ios.subscribe_key + '/0/' +
  channel          + '/0/' +
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
      console.error('Request failed ' + httpResponse.status);
    }
  });
}

// publishes request to IT helpers
function publishRequest(req_channel, requestID, pubnub) {
  var myUrl = 'https://pubsub.pubnub.com/publish/' +
  pubnub.publish_key   +   '/' +
  pubnub.subscribe_key + '/0/' +
  req_channel          + '/0/' +
  '"' + requestID + '"';
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
      console.error('Request failed ' + httpResponse.status);
    }
  });
}

function initalCheckFailed(request, response) {
  if (request.master) {
    console.log("Master making changes. No action taken.");
    if (response) {
        response.success();
    }
    return true;
  }
  if (Parse.User.current() == null) {
    if (response) {
        response.error("Not logged in user");
    }
    return true;
  }
  var username = Parse.User.current().getUsername();
  if (username == null) {
    if (response) {
        response.error("Not logged in username");
    }
    return true;
  }
  return false;
}
