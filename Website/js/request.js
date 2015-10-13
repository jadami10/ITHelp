$(function () {

  $('#requestb').click(function () {
    alert("clicked")
    getReqeusts();
  });

  function getReqeusts() {
    var openRequests = Parse.Object.extend("Request");
    var query = new Parse.Query(openRequests);
    query.equalTo("taken", 0);
    query.find({
      success: function(results) {
        alert("Successfully retrieved " + results.length + " scores.");
        // Do something with the returned Parse.Object values
        for (var i = 0; i < results.length; i++) {
          var object = results[i];
          alert(object.id + ' - ' + object.get('playerName'));
        }
      },
      error: function(error) {
        alert("Error: " + error.code + " " + error.message);
      }
    });
  }


});
