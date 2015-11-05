var NaviBox = React.createClass({
  getInitialState: function() {
    return {num: 0};
  },

  incMyRequestNum: function() {
    this.setState({num: this.state.num+1});
    var badge = this.refs.numBadge;
    $(badge).removeClass("animated");
    setTimeout(function(){$(badge).addClass("animated")}, 10);
  },

  getMyTicketsNumber: function() {
    var openRequests = Parse.Object.extend("Request");
    var currentUser = Parse.User.current();
    var query = new Parse.Query(openRequests);
    var _this = this;

    query.equalTo("helper", currentUser);
    query.find({
      success: function(data) {
        _this.setState({num: data.length});
      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  },

  componentDidMount: function() {
    var curPath = window.location.pathname;
    if (curPath.indexOf("solve") > -1 || curPath === '/') {
      $(this.refs.solve).addClass("navi-current");
    } else if (curPath.indexOf("solving") > -1 || curPath.indexOf("chatting") > -1) {
      $(this.refs.solving).addClass("navi-current");
    }
    this.getMyTicketsNumber();
    $(this.refs.logOut).on("click", function(){
      Parse.User.logOut();
      window.location.href = "/";
    });
  },

  render: function() {
    return (
      <div className="navis">
        <div className="navi-logo">
          <img src="/logo.png" />
        </div>
        <a href="/solve">
          <div className="navi" ref="solve"><span className="fa fa-user-md"></span><span>SOLVE</span></div>
        </a>
        <a href="/solving">
          <div className="navi" ref="solving">
            <span className="fa fa-commenting"></span>
            <span>SOLVING</span>
            <div className="num-badge" ref="numBadge">
              {this.state.num}
            </div>
          </div>
        </a>
        <div className="navi" ref="solved"><span className="fa fa-clock-o"></span><span>SOLVED</span></div>
        <div className="navi log-out" ref="logOut"><span className="fa fa-sign-out"></span><span>Log Out</span></div>
      </div>
    );
  }
});

var naviBox = ReactDOM.render(
  <NaviBox />,
  document.getElementsByClassName('left-navi')[0]
);

var GreetingBox = React.createClass({
  getInitialState: function() {
    return {username: ""};
  },

  getMyUsername: function() {
    var currentUser = Parse.User.current();
    this.setState({username: currentUser.get("username")});
  },

  componentDidMount: function() {
    this.getMyUsername();
    var _this = this;
    $(this.refs.greetingAvatar).on("click", function(){
      $(_this.refs.logOut).fadeToggle("fast");
    });
    $(this.refs.logOut).on("click", function(){
      Parse.User.logOut();
      window.location.href = "/";
    });
  },

  render: function() {
    var curPath = window.location.pathname;
    if (curPath.indexOf("solve") > -1 || curPath === '/') {
      $(this.refs.greetingText).html(
        "<span class='fa fa-sun-o'></span>" + "Hi, " + this.state.username + "."
      );
    } else if (curPath.indexOf("solving") > -1) {
      $(this.refs.greetingText).html("<span class='fa fa-commenting'></span>" + "Current sessions");
    } else if (curPath.indexOf("chatting") > -1) {
      $(this.refs.greetingText).html("<a href='/solving'><span class='fa fa-arrow-left'></span> Session list</a>");
    }

    return (
      <div className="top-greeting-bar">
        <div className="setting-form" ref="logOut">
          <span className="fa fa-sign-out"></span>
          Log Out
        </div>
        <div className="top-left-greetings" ref="greetingText"></div>
        <div className="top-right-avatar" ref="greetingAvatar">
          <span className="top-right-avatar-initial">
            {this.state.username.charAt(0).toUpperCase()}
          </span>
        </div>
      </div>
    );
  }
});

var greetingBox = ReactDOM.render(
  <GreetingBox />,
  document.getElementsByClassName('top-greeting')[0]
);


var updateMyRequestNumber = function() {
  naviBox.incMyRequestNum();
}

window.updateMyRequestNumber = updateMyRequestNumber;
