var Ticket = React.createClass({
  handleClick: function() {
    $(this.refs.desc).toggle('fast');
    $(this.refs.btnHelp).toggle('fast');
  },
  submitHelp: function() {
    // Submit help request here
  },
  render: function() {
    return (
      <div className="prob" onClick={this.handleClick}>
        <div className="wrapper">
          <div className="title"> {this.props.title} </div>
          <div className="desc" ref="desc">
            <span className="fa fa-quote-left"> </span>
            <span> {this.props.children} </span>
            <span className="fa fa-quote-right"></span>
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
    var desc = this.refs.desc.value.trim();
    var time = this.refs.time.value.trim();
    if (!title || !author || !desc || !time) {
      return;
    }
    this.props.onTicketSubmit({author: author, title: title, desc: desc, time: time});
    this.refs.author.value = '';
    this.refs.title.value = '';
    this.refs.desc.value = '';
    this.refs.time.value = '';
  },
  render: function() {
    return (
      <form className="ticketForm" onSubmit={this.handleSubmit}>
        <input type="text" placeholder="name" ref="author" />
        <input type="text" placeholder="title" ref="title" />
        <input type="text" placeholder="brief description" ref="desc" />
        <input type="text" placeholder="time" ref="time" />
        <input type="submit" value="Post" />
      </form>
    );
  }
});

ReactDOM.render(
  <TicketsBox url="/api/tickets" pollInterval={2000} />,
  document.getElementsByClassName('right-probs')[0]
);

