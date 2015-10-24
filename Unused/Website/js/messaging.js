
// use to send message to channel
function sendMessage(message) {
  // TODO: send message
  // Hannah can use this function to send a message
  // This implies she store the channel somewhere
  var newMessage = Parse.Object.extend("Message");
  // set msg text
  // set channel
  var currentUser = Parse.User.current();
  newMessage.save({
    success: function(results) {
      console.log("Successfully saved message");
    },
    error: function(error) {
      alert("Error saving message: " + error.code + " " + error.message);
    }
  });
}

// received message on a channel
function onMessage(message) {
  // TODO: handle new message
  // Hannah should show this message where applicable
  console.log("new message");
  console.log(message);
}
