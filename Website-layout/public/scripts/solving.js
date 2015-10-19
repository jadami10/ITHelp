var Ticket = React.createClass({
  handleClick: function() {
    // goto chatting session
    window.location="../chatting.html";
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

var TicketsBox = React.createClass({
  mixins: [ParseReact.Mixin], // Enable query subscriptions

  observe: function() {
    return {
      tickets: new Parse.Query(Parse.Object.extend("Request")).matchesKeyInQuery("helper", "objectId", Parse.User.current())
    };
  },

  getInitialState: function() {
    return {tickets: []};
  },
  componentDidMount: function() {
  },
  render: function() {
    return (
      <div className="probs">
        <TicketList data={this.data.tickets} />
      </div>
    );
  }
});

var TicketList = React.createClass({
  render: function() {
    var ticketNodes = this.props.data.map(function(ticket, index) {
      return (
        <Ticket author={ticket.author} title={ticket.title} time={ticket.time}  key={index}>
          {ticket.desc}
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

ReactDOM.render(
  <TicketsBox />,
  document.getElementsByClassName('right-probs')[0]
);

