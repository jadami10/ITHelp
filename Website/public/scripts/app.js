var user = {};
var flg = {};
var pb;
var reqChannel;
var messageChannels = {};
var availableRequests = [];
var myRequests = [];

// subscribe to a pubnub channel
function subscribeToChannel(reqChannel, onMessage) {
  if (reqChannel == null) {
    throw "Channel is null";
  } else if (onMessage == null) {
    throw "Null callback function";
  }
  pb.subscribe({
    channel: reqChannel,
    message: function(m){onMessage(m)},
    connect: function() {
      console.log("should be subscribed");
    },
    error: function (error) {
      // Handle error here
      console.log(JSON.stringify(error));
    }
  });

}

function unsubscribeFromChannel(channel) {
  // TODO: unsubscribeFromChannel
}
