import React, { Component, PropTypes } from 'react';
import { takeRequest, subscribeToRequests, subscribeToUser } from '../utils/utils';

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

  handleClick(e) {
    if (e.target.classList[0] == "desc-image") {
      TicketList.showFullscreenImage(this.props.photo["_url"]);
    } else if (e.target.classList[0] != "btn-help") {
      $(this.refs.btnHelp).slideToggle('fast');
      $(this.refs.desc).slideToggle('fast');
    }
  }

  submitHelp() {
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
          <div className="tags" ref="tags"></div>
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
    $(".desc-image-fullscreen-div").on("click", () => {
      $(".desc-image-fullscreen-div").fadeOut("fast")}
    );

    const _this = this;
    const ticketNodes = this.props.tickets.map((ticket, index) => {
      return (
        <Ticket 
          author={ticket.get("requester")} 
          title={ticket.get("title")} 
          time={ticket.get("createdAt").toString().substring(4, 10)} 
          desc={ticket.get("requestMessage")} 
          photo={ticket.get("photoFile")}
          ticketObj={ticket}
          key={index} >
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
    this.onRequestNotification = this.onRequestNotification.bind(this);
  }

  getTickets() {
    const query = new Parse.Query(Parse.Object.extend("Request"))
      .include("tags")
      .equalTo("taken", 0)
      .notEqualTo("allHelpers", Parse.User.current())
      .notEqualTo("requester", Parse.User.current().get("username"));

    const _this = this;

    query.find({
      success: (data) => {
        console.log("Successfully retrieved " + data.length + " requests.");
        _this.setState({data: data});
      },
      error: (error) => {
        console.log("Error: " + error.code + " " + error.message);
      }
    });
  }

  onRequestNotification(n) {
    console.log("onRequestNotification: " + n.requestType);
    let tmpData = this.state.data;

    if (n.requestType === "TicketTaken" || n.requestType === "TicketDeleted") {
      // hide the ticket
      for (let d = 0; d < tmpData.length; d += 1) {
        if (this.state.data[d].id === n.requestID) {
          tmpData.splice(d, 1);
          this.setState(tmpData);
          return;
        }
      }

    } else if (n.requestType === "TicketAdded" || n.requestType === "TicketReadded") {
      // add the ticket
      const query = new Parse.Query(Parse.Object.extend("Request"))
        .include("tags")
        .equalTo("objectId", n.requestID)
        // .noEqualTo("allHelpers", Parse.User.current())
        .notEqualTo("requester", Parse.User.current().get("username"));

      const _this = this;

      query.first({
        success: (request) => {
          tmpData.push(request);
          _this.setState(request);
          return;
        },
        error: (error) => {
          console.log("Error: " + error.code + " " + error.message);
        }
      });

    } else if (n.requestType === "TicketGranted") {
      // increment the badge
      this.props.updateSolvingBadge(1);

    } else if (n.requestType === "TicketSolved") {
      this.props.updateSolvedBadge(-1);

    } else if (n.requestType === "RequestSolved") {
      // TODO: hide ticket from solving
      this.props.updateSolvingBadge(-1);
    } else {
      console.log("Error: onRequestNotification");
    }
  }

  componentDidMount() {
    this.getTickets();

    subscribeToRequests(this.onRequestNotification);
    subscribeToUser(Parse.User.current().id, this.onRequestNotification);
  }

  render() {
    return (
      <div id="solve">
        <div className="probs">
          <TicketList tickets={this.state.data} />
        </div>
      </div>
    );
  }
};

export default SolveTicketsBox;
