var Msg = React.createClass({
  render: function() {
    return (
      <div className="msg-block">
        <div className={this.props.source + " msg"}>
          {this.props.children}
        </div>
      </div>
    );
  }
});

var ChatBox = React.createClass({
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
  handleMsgSubmit: function(newMsg) {
    var data = this.state.data;
    var newData = data.concat([newMsg]);
    this.setState({data: newData});
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      type: 'POST',
      data: newMsg,
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
      <div className="chat-box">
        <MsgList data={this.state.data} />
        <ChatForm onMsgSubmit={this.handleMsgSubmit} />
        <ChatFormTest onMsgSubmit={this.handleMsgSubmit} />
      </div>
    );
  }
});

var MsgList = React.createClass({
  render: function() {
    var msgNodes = this.props.data.map(function(msg, index) {
      return (
        <Msg source={msg.source} key={index}>
          {msg.content}
        </Msg>
      );
    });
    return (
      <div className="chat-content">
        {msgNodes}
      </div>
    );
  }
});

var ChatForm = React.createClass({
  handleSubmit: function(e) {
    e.preventDefault();
    var content = this.refs.content.value.trim();
    if (!content) {
      return;
    }
    this.props.onMsgSubmit({source: "sent", content: content});
    this.refs.content.value = '';
  },
  render: function() {
    return (
      <form className="chat-form" onSubmit={this.handleSubmit}>
        <input className="input-text" type="text" placeholder="say something..." ref="content" />
        <div className="send-text" type="submit"> Send </div>
      </form>
    );
  }
});

var ChatFormTest = React.createClass({
  handleSubmit: function(e) {
    e.preventDefault();
    var content = this.refs.content.value.trim();
    if (!content) {
      return;
    }
    this.props.onMsgSubmit({source: "received", content: content});
    this.refs.content.value = '';
  },
  render: function() {
    return (
      <form className="chat-form" onSubmit={this.handleSubmit}>
        <input className="input-text" type="text" placeholder="say something..." ref="content" />
        <div className="send-text" type="submit"> Receive </div>
      </form>
    );
  }
});

ReactDOM.render(
  <ChatBox url="/api/msgs" pollInterval={2000} />,
  document.getElementsByClassName('right-chat')[0]
);
