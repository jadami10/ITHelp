import React, { Component, PropTypes } from 'react';
import { render } from 'react-dom';
import { Router, Route, IndexRoute, Link, Navigation } from 'react-router';
import { getAvailableRequests, subscribeToRequests } from './utils/utils';
import history from './utils/history'
import {checkAuth, requireAuth} from './utils/auth'

import Auth from './components/Auth';

import NaviBox from './components/NaviBox';
import GreetingBox from './components/GreetingBox';
import SolveTicketsBox from './components/SolveTicketsBox';
import SolvingTicketsBox from './components/SolvingTicketsBox';
import ChatBox from './components/ChatBox';

class Entry extends React.Component {
  render() {
    return (
      <div>
          {this.props.children}
      </div>
    )
  }
};

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {badgeNum: 0}

    this.getMyTicketsNumber = this.getMyTicketsNumber.bind(this);
    this.update = this.update.bind(this);
  }

  update() {
    this.setState({badgeNum: this.state.badgeNum+1});
  }

  componentDidMount() {
    this.getMyTicketsNumber();
  }

  getMyTicketsNumber() {
    let openRequests = Parse.Object.extend("Request");
    let currentUser = Parse.User.current();
    let query = new Parse.Query(openRequests);
    let that = this;

    query.equalTo("helper", currentUser);
    query.notEqualTo("helperSolved", 1);
    query.find({
      success: function(data) {
        that.setState({badgeNum: data.length});
      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  }

  render() {
    return (
      <div>
        <div className="top-greeting">
          <GreetingBox />
        </div>
        <div className="left-navi">
          <NaviBox badgeNum={this.state.badgeNum} />
        </div>
        <div className="right-content">
          {React.cloneElement(this.props.children, {update: this.update})}
        </div>
      </div>
    )
  }
};

const Routes = (
  <Router history={history}>
    <Route path="/" component={Entry}>
      <IndexRoute component={Auth} onEnter={checkAuth}/>

      <Route path="login" component={Auth} onEnter={checkAuth}/>

      <Route path="app" component={App} onEnter={requireAuth}>
        <IndexRoute component={SolveTicketsBox}/>
        <Route path="solve" component={SolveTicketsBox}/>
        <Route path="solving" component={SolvingTicketsBox}/>
        <Route path="chat/:id" component={ChatBox}/>
      </Route>
    </Route>

  </Router>
)

render((
  Routes
), document.querySelector(".content"))

export default Routes
