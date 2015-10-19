var Ticket = React.createClass({
  handleClick: function() {
    // goto chatting session
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
  loadDataFromServer: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  handleTicketSubmit: function(newTicket) {
    var data = this.state.data;
    var newData = data.concat([newTicket]);
    this.setState({data: newData});
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      type: 'POST',
      data: newTicket,
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {data: []};
  },
  componentDidMount: function() {
    this.loadDataFromServer();
    setInterval(this.loadDataFromServer, this.props.pollInterval);
  },
  render: function() {
    return (
      <div className="probs">
        <TicketList data={this.state.data} />
        <TicketForm onTicketSubmit={this.handleTicketSubmit} />
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
      <div className="ticketList">
        {ticketNodes}
      </div>
    );
  }
});

var TicketForm = React.createClass({
  handleSubmit: function(e) {
    e.preventDefault();
    var author = this.refs.author.value.trim();
    var title = this.refs.title.value.trim();
    if (!title || !author) {
      return;
    }
    this.props.onTicketSubmit({author: author, title: title});
    this.refs.author.value = '';
    this.refs.title.value = '';
  },
  render: function() {
    return (
      <form className="ticketForm" onSubmit={this.handleSubmit}>
        <input type="text" placeholder="name" ref="author" />
        <input type="text" placeholder="title" ref="title" />
        <input type="submit" value="Post" />
      </form>
    );
  }
});

ReactDOM.render(
  <TicketsBox url="/api/chats" pollInterval={2000} />,
  document.getElementsByClassName('right-probs')[0]
);

