$('#signupb').click(function () {
  if (flg.logt == 0) {
    signup()
  } else if (flg.logt == 1) {
    login()
  }
});

function login() {
  var id = $('#name').val();
  var pass = $('#pass').val();
  Parse.User.logIn(id, pass, {
    success: function(user) {
      alert("Good login")
    },
    error: function(user, error) {
      switch(error.code) {
        case 100:
        alert("No Network Connection");
        break;
        case 101:
        alert("Bad ID and/or Pass");
        break;
        default:
        Parse.User.logOut()
        alert("Error: " + error.code + " " + error.message);
      }
    }
  });
}

function signup() {
  var user = new Parse.User();
  var first = $('#first').val()
  var last = $('#last').val()
  var email = $('#email').val()
  var id = $('#name').val()
  var pass = $('#pass').val()
  user.set("username", id);
  user.set("password", pass);
  user.set("email", email);
  user.set("first", first);
  user.set("last", last);

  user.signUp(null, {
    success: function(user) {
      // Hooray! Let them use the app now.
      alert("Good sign up!");
    },
    error: function(user, error) {
      // Show the error message somewhere and let the user try again.
      switch(error.code) {
        case 100:
        alert("No Network Connection");
        break;
        case 125:
        alert("Bad Email Format");
        break;
        case 202:
        alert("Username Taken");
        break;
        case 203:
        alert("Email Taken");
        break;
        default:
        alert("Error: " + error.code + " " + error.message);
      }
    }
  });
}
