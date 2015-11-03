var FormBox = React.createClass({

  getInitialState: function() {
    return {signingUp: false};
  },

  onSigningUp: function() {
    this.setState({signingUp: true});
    $(".login-button").fadeToggle("fast");
    $(".signup-switch-button").fadeToggle("fast");
    $(".reminder").fadeToggle("fast");
    $(".signup-input").fadeToggle("fast");
  },

  handleSubmit: function(e) {
    e.preventDefault();

    if (this.state.signingUp == false) {
      // logging in
      var username = this.refs.username.value.trim();
      var pswd = this.refs.pswd.value.trim();
      if (!pswd || !username) {
        window.alert("Wrong username/password. (For testing, please use hannah/hannah)");
        return;
      }

      Parse.User.logIn(username, pswd, {
          success: function(user) {
            console.log("logged in"); 
            window.location.href = "/solve";
          },
          error: function(user, err) {
            window.alert("Wrong username/password. (For testing, please use hannah/hannah)");
            this.refs.username.value = '';
            this.refs.pswd.value = '';
          }
      });
    } else {
      // signing up

      var username = this.refs.username.value.trim();
      var pswd = this.refs.pswd.value.trim();
      var fname = this.refs.fname.value.trim();
      var lname = this.refs.lname.value.trim();
      var email = this.refs.email.value.trim();
      if (!pswd || !username || !fname || !lname || !email) {
        window.alert("Missing fields");
        return;
      }

      var user = new Parse.User();
      user.set("username", username);
      user.set("password", pswd);
      user.set("email", email);
      user.set("first", fname);
      user.set("last", lname);

      user.signUp(null, {
        success: function(user) {
          window.alert("Hooray! You are all set.")
          Parse.User.logIn(username, pswd, {
            success: function(user) {
              console.log("logged in"); 
              window.location.href = "/solve";
            },
            error: function(user, err) {
              window.alert("Oops something is wrong. Please try again.");
            }
          });
        },
        error: function(user, error) {
          switch (error.code) {
            case 100: window.alert("Please check network connection."); break;
            case 125: window.alert("Bad email format."); break;
            case 202: window.alert("Please pick different username."); break;
            case 203: window.alert("Please pick different email."); break;
            default: window.alert("Oops something is wrong. Please try later."); 
          }
        }
      });
    }
  },

  render: function() {
    return (
      <div className="formBox">
        <form className="inputForm" onSubmit={this.handleSubmit} ref="inputForm">

          <div className="input-set login-input">
            <span className="fa fa-user"></span>
            <input type="text" placeholder="Your name" ref="username" />
          </div>
          <div className="input-set login-input">
            <span className="fa fa-lock"></span>
            <input type="password" placeholder="Password" ref="pswd" />
          </div>

          <div className="input-set signup-input">
            <span className="fa fa-caret-right"></span>
            <input type="text" placeholder="First Name" ref="fname" />
          </div>
          <div className="input-set signup-input">
            <span className="fa fa-caret-right"></span>
            <input type="text" placeholder="Last Name" ref="lname" />
          </div>
          <div className="input-set signup-input">
            <span className="fa fa-envelope"></span>
            <input type="text" placeholder="E-mail" ref="email" />
          </div>

          <input type="submit" className="button login-button" value="Log In" />
          <input type="submit" className="button signup-button signup-input" value="Sign Up & Log In" />
          <div className="reminder">
            Don&apos;t have an account yet?
          </div>
        </form>

        <input type="submit" className="button signup-button signup-switch-button" value="Sign Up" onClick={this.onSigningUp} />
      </div>
    );
  }
});

ReactDOM.render(
  <FormBox />,
  document.getElementsByClassName('login-form')[0]
);

