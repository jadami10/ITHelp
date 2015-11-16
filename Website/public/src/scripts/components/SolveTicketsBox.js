import React, { Component, PropTypes } from 'react';
import { takeRequest, subscribeToRequests } from '../utils/utils';

class Ticket extends React.Component {

  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
    this.submitHelp = this.submitHelp.bind(this);
  }

  componentDidMount() {
    $(this.refs.btnHelp).hide();
    if (this.props.photo != null) {
      this.refs.descImage.src = this.props.photo["_url"];
      $(this.refs.descImage).show();
    }
  }

  handleClick(e) {
    if (e.target.classList[0] == "desc-image") {
      TicketList.showFullscreenImage(this.props.photo["_url"]);
    } else if (e.target.classList[0] != "btn-help") {
      $(this.refs.btnHelp).slideToggle('fast');
      $(this.refs.desc).slideToggle('fast');
    }
  }

  submitHelp() {
    // TODO: update navi
    this.props.update();
    takeRequest(this.props.ticketObj);

  }

  render() {
    return (
      <div className="prob" onClick={this.handleClick} ref="curTicket">
        <div className="wrapper-title">
          <div className="title"> {this.props.title} </div>
        </div>
        <div className="wrapper">
          <div className="desc" ref="desc">
            <span className="fa fa-quote-left"> </span>
            <span> {this.props.desc} </span>
            <span className="fa fa-quote-right"></span>
            <img className="desc-image" ref="descImage" />
          </div>
          <div className="tag adobe"></div>
          <div className="tag software"></div>
          <div className="request-bottom">
            <div className="requester"> 
              <span className="fa fa-user"></span>
              <span>{this.props.author}</span>
            </div>
            <div className="request-time">
              <span className="fa fa-clock-o"></span>
              <span>{this.props.time}</span>
            </div>
          </div>
        </div>
        <div className="btn-help" ref="btnHelp" onClick={this.submitHelp}></div>
      </div>
    );
  }
};

class TicketList extends React.Component {
  static showFullscreenImage(s) {
    $(".desc-image-fullscreen").attr("src", s);
    $(".desc-image-fullscreen-div").fadeIn("fast")
  }

  render() {
    $(".desc-image-fullscreen-div").on("click", function() {
      $(".desc-image-fullscreen-div").fadeOut("fast")}
    );

    var that = this;
    var ticketNodes = this.props.tickets.map(function(ticket, index) {
      return (
        <Ticket 
          author={ticket.get("requester")} 
          title={ticket.get("title")} 
          time={ticket.get("createdAt").toString().substring(4, 10)} 
          desc={ticket.get("requestMessage")} 
          photo={ticket.get("photoFile")}
          ticketObj={ticket}
          key={index}
          update={that.props.update} >
        </Ticket>
      );
    });
    return (
      <div className="ticket-list">
        {ticketNodes}
        <div className="desc-image-fullscreen-div">
          <img className="desc-image-fullscreen" />              
        </div>
      </div>
    );
  }
};

class SolveTicketsBox extends React.Component {

  constructor(props) {
    super(props);
    this.state = {data: []};
    this.getTickets = this.getTickets.bind(this);
  }

  getTickets() {
    var openRequests = Parse.Object.extend("Request");
    var query = new Parse.Query(openRequests);
    var _this = this;

    query.equalTo("taken", 0);
    query.find({
      success: function(data) {
        console.log("Successfully retrieved " + data.length + " requests.");
        _this.setState({data: data});
      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  }

  componentDidMount() {
    this.getTickets();
    subscribeToRequests(this.getTickets);
  }

  render() {
    return (
      <div id="solve">
        <div className="probs">
          <TicketList tickets={this.state.data} update={this.props.update} />
        </div>
      </div>
    );
  }
};

export default SolveTicketsBox;
