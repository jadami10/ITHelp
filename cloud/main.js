
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave("Request", function(request) {
  /*
  // Get the movie id for the Review
  var movieId = request.object.get("movie").id;
  // Query the Movie represented by this review
  var Movie = Parse.Object.extend("Movie");
  var query = new Parse.Query(Movie);
  query.get(movieId).then(function(movie) {
    // Increment the reviews field on the Movie object
    movie.increment("reviews");
    movie.save();
  }, function(error) {
    throw "Got an error " + error.code + " : " + error.message;
  });
  */

  // send to pubnub
});
