import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router'
import { subscribeToChat } from '../utils/utils';

class Ticket extends React.Component {

  constructor(props) {
    super(props);
    this.markSolve = this.markSolve.bind(this);
    this.markGiveup = this.markGiveup.bind(this);
  }

  componentDidMount() {
    const tags = this.props.ticketObj.get("tags");
    for (let i = 0; i < tags.length; i += 1) {
      const tagName = tags[i].get("Name");
      switch(tagName) {
        case "Mac": $(this.refs.tags).append("<div class='tag mac'></div>"); break;
        case "Software": $(this.refs.tags).append("<div class='tag software'></div>"); break;
        case "Hardware": $(this.refs.tags).append("<div class='tag hardware'></div>"); break;
        case "Windows": $(this.refs.tags).append("<div class='tag windows'></div>"); break;
        case "Other": $(this.refs.tags).append("<div class='tag other'></div>"); break;
        default: console.log("Tag error");
      }
    }
  }

  markSolve() {
    // maybe a confirm box?

    const currentUser = Parse.User.current();
    const requestObject = this.props.ticketObj;
    const _this = this;

    requestObject.set({
      helperSolved: 1
    });

    requestObject.save(null, {
      success: function(reqObject) {
        // decrease solving badge
        _this.props.updateSolvingBadge(-1);
        // increase solved badge
        _this.props.updateSolvedBadge(1);

        window.alert("You have successfully marked the ticket as solved. Pending accepted.");
        $(_this.refs.prob).hide();
      },
      error: function(reqObject, error) {
        console.log("Failed to solve the ticket with error: " + error.code + " " + error.message);
      }
    });
  }

  markGiveup() {
    const currentUser = Parse.User.current();
    const requestObject = this.props.ticketObj;
    const _this = this;

    requestObject.set({
      taken: 0
    });
    requestObject.unset("helper");

    requestObject.save(null, {
      success: function(reqObject) {
        // decrease solving badge
        _this.props.updateSolvingBadge(-1);

        window.alert("You have successfully given up the ticket. (Think twice before picking up a ticket next time!)");
        $(_this.refs.prob).hide();
      },
      error: function(reqObject, error) {
        console.log("Failed to give up the ticket with error: " + error.code + " " + error.message);
      }
    });
  }

  render() {
    return (
      <div className="prob" ref="prob">
        <div className="wrapper-left">
          <div className="btn-mark btn-solve" ref="btnSolve" onClick={this.markSolve}>
            <span className="fa fa-check"></span>
          </div>
          <div className="btn-mark btn-giveup" ref="btnGiveup" onClick={this.markGiveup}>
            <span className="fa fa-close"></span>
          </div>
        </div>
        <Link to={`/app/chat/${this.props.id}`}>
          <div className="wrapper-right">
            <div className="title"> {this.props.title} </div>
            <div className="tags" ref="tags"></div>
            <div className="requester"> 
              <span className="fa fa-user"></span>
              <span>{this.props.author}</span>
            </div>
          </div>
        </Link>
      </div>
    );
  }
};

class TicketList extends React.Component {
  render() {
    const ticketNodes = this.props.tickets.map((ticket, index) => {
      return (
        <Ticket 
          author={ticket.get("requester")} 
          title={ticket.get("title")} 
          time={ticket.get("createdAt").toString().substring(0, 10)} 
          id={ticket.id}
          key={index}
          ticketObj={ticket}
          updateSolvedBadge={this.props.updateSolvedBadge}
          updateSolvingBadge={this.props.updateSolvingBadge}>
          {ticket.get("requestMessage")}
        </Ticket>
      );
    });
    return (
      <div className="ticket-list">
        {ticketNodes}
      </div>
    );
  }
};

class SolvingTicketsBox extends React.Component {

  constructor(props) {
    super(props);
    this.state = {data: []};
    this.getTickets = this.getTickets.bind(this);
  }

  getTickets() {
    const query = new Parse.Query(Parse.Object.extend("Request"))
      .include("tags")
      .equalTo("helper", Parse.User.current())
      .notEqualTo("helperSolved", 1);

    const _this = this;

    query.find({
      success: function(data) {
        _this.setState({data: data});
      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  }

  componentDidMount() {
    this.getTickets();
  }

  // componentWillReceiveProps(nextProps) {
  //   console.log("solvingTicket: ")
  //   console.log(this.props.solvingTicket)
  //   if (!(nextProps.solvingTicket.length == this.props.solvingTicket.length)) {
  //     // hide the ticket
  //     let tmpData = this.state.data;
  //     for (let id = 0; id < this.props.solvingTicket.length; id += 1) {
  //     for (let d = 0; d < tmpData.length; d += 1) {
  //       if (this.state.data[d].id === this.props.solvingTicket[id]) {
  //         tmpData.splice(d, 1);
  //       }
  //     }}
  //     this.setState(tmpData);
  //     return;
  //   }
  // }

  render() {
    return (
      <div id="solving">
        <div className="probs">
          <TicketList 
            tickets={this.state.data} 
            updateSolvedBadge={this.props.updateSolvedBadge}
            updateSolvingBadge={this.props.updateSolvingBadge} />
        </div>
      </div>
    );
  }
};

export default SolvingTicketsBox;
