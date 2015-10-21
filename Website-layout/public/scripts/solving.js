var Ticket = React.createClass({
  handleClick: function() {
    // goto chatting session
    
    window.location="../chatting.html?id=" + this.props.id;
  },
  render: function() {
    return (
      <div className="prob" onClick={this.handleClick}>
        <div className="wrapper">
          <div className="title"> {this.props.title} </div>
          <div className="tag hardware"></div>
          <div className="requester"> 
            <span className="fa fa-user"></span>
            <span>{this.props.author}</span>
          </div>
        </div>
      </div>
    );
  }
});

var TicketList = React.createClass({
  render: function() {
    var ticketNodes = this.props.tickets.map(function(ticket, index) {
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
});

var TicketsBox = React.createClass({

  getInitialState: function() {
    return {data: []};
  },

  getTickets: function() {
    var openRequests = Parse.Object.extend("Request");
    var currentUser = Parse.User.current();
    var query = new Parse.Query(openRequests);
    var _this = this;

    query.matchesKeyInQuery("helper", "objectId", currentUser);
    query.find({
      success: function(data) {
        if (data.length > 0) {
          for (var i = 0; i < data.length; i++) {
            subscribeToChat(data[i]);
            // if (doSubscribe) {
            //   subscribeToChat(result);
            // }
          }
        }
        console.log("Successfully retrieved " + data.length + " scores.");
        _this.setState({data: data});
      },
      error: function(error) {
        alert("Error: " + error.code + " " + error.message);
      }
    });
  },

  componentDidMount: function() {
    this.getTickets();
  },

  render: function() {
    return (
      <div className="probs">
        <TicketList tickets={this.state.data} />
      </div>
    );
  }
});

ReactDOM.render(
  <TicketsBox />,
  document.getElementsByClassName('right-probs')[0]
);

