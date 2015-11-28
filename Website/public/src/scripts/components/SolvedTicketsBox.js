import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router'

class Ticket extends React.Component {

  constructor(props) {
    super(props);
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

  render() {
    return (
      <div className="prob" ref="prob">
        <div className="wrapper">
          <div className="title"> {this.props.title} </div>
          <div className="tags" ref="tags"></div>
          <div className="requester"> 
            <span className="fa fa-user"></span>
            <span>{this.props.author}</span>
          </div>
        </div>
      </div>
    );
  }
};

class TicketList extends React.Component {
  render() {
    if (this.props.tickets.length > 0) {
      const ticketNodes = this.props.tickets.map((ticket, index) => {
        return (
          <Ticket 
            author={ticket.get("requester")} 
            title={ticket.get("title")} 
            time={ticket.get("createdAt").toString().substring(0, 10)} 
            id={ticket.id}
            key={index}
            ticketObj={ticket}>
            {ticket.get("requestMessage")}
          </Ticket>
        );
      });
      return (
        <div className="ticket-list">
          {ticketNodes}
        </div>
      );
    } else {
      return (
        <div className="prob-blank">
        </div>
      );
    }
  }
};

class SolvedTicketsBox extends React.Component {

  constructor(props) {
    super(props);
    this.state = {pendingData: [], historyData: []};
    this.getPendingTickets = this.getPendingTickets.bind(this);
    this.getHistoryTickets = this.getHistoryTickets.bind(this);
  }

  getPendingTickets() {
    const query = new Parse.Query(Parse.Object.extend("Request"))
      .include("tags")
      .equalTo("helper", Parse.User.current())
      .equalTo("helperSolved", 1)
      .equalTo("requesterSolved", -1);

    const _this = this;

    query.find({
      success: function(data) {
        _this.setState({pendingData: data});
      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  }

  getHistoryTickets() {
    const query = new Parse.Query(Parse.Object.extend("Request"))
      .include("tags")
      .equalTo("helper", Parse.User.current())
      .equalTo("requesterSolved", 1);

    const _this = this;

    query.find({
      success: function(data) {
        _this.setState({historyData: data});
      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  }

  componentDidMount() {
    this.getPendingTickets();
    this.getHistoryTickets();
  }

  render() {
    return (
      <div id="solved">
        <div className="data-title">
          Pending tickets
        </div>
        <div className="probs">
          <TicketList tickets={this.state.pendingData} />
        </div>

        <div className="data-title" style={{paddingTop: "30px"}}>
          History tickets
        </div>
        <div className="probs">
          <TicketList tickets={this.state.historyData} />
        </div>
      </div>
    );
  }
};

export default SolvedTicketsBox;
