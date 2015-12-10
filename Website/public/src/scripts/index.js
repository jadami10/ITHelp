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
import SolvedTicketsBox from './components/SolvedTicketsBox';
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
    this.state = {solvingBadgeNum: 0, solvedBadgeNum : 0}

    this.getSolvingNumber = this.getSolvingNumber.bind(this);
    this.getSolvedNumber = this.getSolvedNumber.bind(this);
    this.updateSolvingBadge = this.updateSolvingBadge.bind(this);
    this.updateSolvedBadge = this.updateSolvedBadge.bind(this);
  }

  updateSolvingBadge(num) {
    this.setState({solvingBadgeNum: Math.max(this.state.solvingBadgeNum + num, 0)});
  }

  updateSolvedBadge(num) {
    this.setState({solvedBadgeNum: this.state.solvedBadgeNum + num});
  }

  componentDidMount() {
    this.getSolvingNumber();
    this.getSolvedNumber();
  }

  getSolvingNumber() {
    const query = new Parse.Query(Parse.Object.extend("Request"))
      .equalTo("helper", Parse.User.current())
      .notEqualTo("helperSolved", 1)
      .notEqualTo("requesterSolved", 1);

    const _this = this;

    query.find({
      success: function(data) {
        _this.setState({solvingBadgeNum: data.length});
      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  }

  getSolvedNumber() {
    const query = new Parse.Query(Parse.Object.extend("Request"))
      .equalTo("helper", Parse.User.current())
      .equalTo("helperSolved", 1)
      .equalTo("requesterSolved", -1);

    const _this = this;

    query.find({
      success: function(data) {
        _this.setState({solvedBadgeNum: data.length});
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
          <NaviBox badgeNum={{
            solving: this.state.solvingBadgeNum, 
            solved: this.state.solvedBadgeNum}} />
        </div>
        <div className="right-content">
          {React.cloneElement(
            this.props.children, 
            {updateSolvingBadge: this.updateSolvingBadge, 
              updateSolvedBadge: this.updateSolvedBadge})}
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
        <Route path="solved" component={SolvedTicketsBox}/>
      </Route>
    </Route>

  </Router>
)

render((
  Routes
), document.querySelector(".content"))

export default Routes
