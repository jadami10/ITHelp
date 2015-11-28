import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router'
import history from '../utils/history'

class NaviBox extends React.Component {

  componentWillReceiveProps(nextProps) {
    // Animate the badge
    if (!(nextProps.badgeNum.solving == this.props.badgeNum.solving 
        && nextProps.badgeNum.solved == this.props.badgeNum.solved )) {
      const numBadge = this.refs.numBadge;
      $(numBadge).removeClass("animated");
      setTimeout(() => {$(numBadge).addClass("animated")}, 10);
    }
  }

  componentWillUpdate() {
    const curPath = window.location.pathname;
    $(this.refs.solve).removeClass("navi-current");
    $(this.refs.solving).removeClass("navi-current");
    $(this.refs.solved).removeClass("navi-current");

    if (curPath.indexOf("solved") > -1) {
      $(this.refs.solved).addClass("navi-current");
    } else if (curPath.indexOf("solve") > -1 || curPath === '/app') {
      $(this.refs.solve).addClass("navi-current");
    } else if (curPath.indexOf("solving") > -1 || curPath.indexOf("chat") > -1) {
      $(this.refs.solving).addClass("navi-current");
    }
    $(this.refs.logOut).on("click", function(){
      Parse.User.logOut();
      history.replaceState(null, '/login');
    });
  }

  render() {
    return (
      <div className="navis">
        <div className="navi-logo">
          <img src="/assets/logo.png" />
        </div>

        <Link to="/app/solve">
          <div className="navi navi-current" ref="solve">
            <span className="fa fa-user-md"></span>
            <span>SOLVE</span>
          </div>
        </Link>

        <Link to="/app/solving">
          <div className="navi" ref="solving">
            <span className="fa fa-commenting"></span>
            <span>SOLVING</span>
            <div className="num-badge" ref="numBadge">
              {this.props.badgeNum.solving}
            </div>
          </div>
        </Link>

        <Link to="/app/solved">
          <div className="navi" ref="solved">
            <span className="fa fa-clock-o"></span>
            <span>SOLVED</span>
            <div className="num-badge" ref="numBadge">
              {this.props.badgeNum.solved}
            </div>
          </div>
        </Link>

        <div className="navi log-out" ref="logOut">
          <span className="fa fa-sign-out"></span>
          <span>Log Out</span>
        </div>
      </div>
    );
  }
};

export default NaviBox;
