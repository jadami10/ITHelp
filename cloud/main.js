var pubnub = {
  'publish_key': 'pub-c-0239b592-0603-4849-9889-ce70e8d18cb7',
  'subscribe_key': 'sub-c-8e935f6a-6eb4-11e5-95b8-0619f8945a4f'
};
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var req_channel = "RequestChannel";

// publish request to pubnub after it's added
Parse.Cloud.afterSave("Request", function(request) {

  // send to pubnub
  var taker = request.user;
  var taken = request.object.get("taken");
  var helper = request.object.get("helper");
  var reqID = request.object.id;
  if (taken == 0) {
    console.log("publishing new request");
    publishRequest(reqID);
  } else if (taken == 1 && taker != null && helper == null) {
    console.log("someone taking request");
    request.object.set("helper", taker);
    request.object.save();
  } else {
    console.log("did nothing -_-");
  }

});

Parse.Cloud.afterSave("Message", function(message) {

  // send to pubnub
  var channel = message.get("channel");
  sendMessage(channel, message);

});

// send a message to a channel
function sendMessage(channel, message) {
  Parse.Cloud.httpRequest({
    url: 'http://pubsub.pubnub.com/publish/' +
    pubnub.publish_key   +   '/' +
    pubnub.subscribe_key + '/0/' +
    channel          + '/0/' +
    encodeURIComponent(JSON.stringify(message)),

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
function publishRequest(requestID) {
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
