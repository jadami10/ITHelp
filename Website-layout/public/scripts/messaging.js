function subscribeToChat(requestObject) {
  try {
    //var channel = requestObject.get("comChannel");
    var channel = requestObject.id;
    subscribeToChannel(channel, onMessage);
  } catch(err) {
    console.log("Could not subscribe: " + err);
  }
}

// received message on a channel
function onMessage(message) {
  // TODO: handle new message
  // Hannah should show this message where applicable
  updateMsg(message);
  console.log("new message");
  console.log(message);
}
