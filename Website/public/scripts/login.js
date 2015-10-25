var LoginBox = React.createClass({
  handleSubmit: function(e) {
    e.preventDefault();

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
  },
  render: function() {
    return (
      <form className="loginForm" onSubmit={this.handleSubmit}>
        <div className="input-set">
          <span className="fa fa-envelope-o"></span>
          <input type="text" placeholder="Your name" ref="username" />
        </div>
        <div className="input-set">
          <span className="fa fa-lock"></span>
          <input type="password" placeholder="Password" ref="pswd" />
        </div>
        <input type="submit" className="login-button" value="Log In" />
      </form>
    );
  }
});

ReactDOM.render(
  <LoginBox />,
  document.getElementsByClassName('login-form')[0]
);

