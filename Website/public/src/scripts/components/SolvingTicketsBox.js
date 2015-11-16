import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router'
import { subscribeToChat } from '../utils/utils';

class Ticket extends React.Component {
  render() {
    return (
      <div className="prob">
        <Link to={`/app/chat/${this.props.id}`}>
          <div className="wrapper">
            <div className="title"> {this.props.title} </div>
            <div className="tag hardware"></div>
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
          key={index}>
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
      .equalTo("helper", Parse.User.current())
      .notEqualTo("helperSolved", 1);

    const _this = this;

    query.find({
      success: function(data) {
        // if (data.length > 0) {
        //   for (var i = 0; i < data.length; i++) {
        //     console.log(data[i].get("helper"));
        //     subscribeToChat(data[i]);
        //   }
        // }
        // console.log("Successfully retrieved " + data.length + " scores.");
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

  render() {
    return (
      <div id="solving">
        <div className="probs">
          <TicketList tickets={this.state.data} />
        </div>
      </div>
    );
  }
};

export default SolvingTicketsBox;
