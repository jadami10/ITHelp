import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router'
import history from '../utils/history'

class GreetingBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {username: ""};
    this.getMyUsername = this.getMyUsername.bind(this);
  }

  getMyUsername() {
    const currentUser = Parse.User.current();
    this.setState({username: currentUser.get("username")});
  }

  componentDidMount() {
    this.getMyUsername();
    const _this = this;

    $(this.refs.greetingAvatar).on("click", () => {
      $(_this.refs.logOut).fadeToggle("fast");
    });
    $(this.refs.logOut).on("click", () => {
      Parse.User.logOut();
      history.replaceState(null, '/login');
    });
  }

  render() {
    const curPath = window.location.pathname;

    $(this.refs.gGreetings).hide();
    $(this.refs.gBack).hide();
    $(this.refs.gSessions).hide();
    if (curPath.indexOf("solve") > -1 || curPath === '/app') {
      $(this.refs.gGreetings).show();
    } else if (curPath.indexOf("solving") > -1) {
      $(this.refs.gSessions).show();
    } else if (curPath.indexOf("chat") > -1) {
      $(this.refs.gBack).show();
    }

    return (
      <div className="top-greeting-bar">
        <div className="setting-form" ref="logOut">
          <span className="fa fa-sign-out"></span>
          Log Out
        </div>
        <div className="top-left-greetings" ref="greetingText">
          <div ref="gGreetings">
            <span className='fa fa-sun-o'></span> Hi, {this.state.username}.
          </div>
          <div ref="gSessions">
            <span className='fa fa-commenting'></span> Current sessions
          </div>
          <div ref="gBack">
            <Link to='/app/solving'>
              <span className='fa fa-arrow-left'></span> Session list
            </Link>
          </div>
        </div>
        <div className="top-right-avatar" ref="greetingAvatar">
          <span className="top-right-avatar-initial">
            {this.state.username.charAt(0).toUpperCase()}
          </span>
        </div>
      </div>
    );
  }
};

export default GreetingBox;
