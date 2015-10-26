var Msg = React.createClass({
  getInitialState: function() {
    return {source: "sent"};
  },
  
  getMsgSource: function() {
    if (this.props.source === Parse.User.current().get("username")) {
      this.state.source = "sent";
    } else {
      this.state.source = "received";
    }
  },

  componentWillMount: function() {
    this.getMsgSource();
  },

  render: function() {
    return (
      <div className="msg-block">
        <div className={this.state.source + " msg"}>
          {this.props.children}
        </div>
      </div>
    );
  }
});

var MsgList = React.createClass({
  componentDidUpdate: function(p, s) {
    var chatContentDiv = this.refs.chatContent;
    chatContentDiv.scrollTop = chatContentDiv.scrollHeight;
  },

  render: function() {
    var msgNodes = this.props.data.map(function(msg, index) {
      return (
        <Msg source={msg.get("sender")} key={index}>
          {msg.get("message")}
        </Msg>
      );
    });

    if (this.props.additionalData) {
      console.log("addtionalData!!");
      var additionalMsgNodes = this.props.additionalData.map(function(msg, index) {
        return (
          <Msg source={msg.sender} key={index}>
            {msg.message}
          </Msg>
        );
      });
      return (
        <div className="chat-content" ref="chatContent">
          {msgNodes}
          {additionalMsgNodes}
        </div>
      );
    } else return (
      <div className="chat-content" ref="chatContent">
        {msgNodes}
      </div>
    );
  }
});

var ChatBox = React.createClass({
  getInitialState: function() {
    return {
      requestObj: [],
      additionalData: [],
      data: []
    };
  },

  addMsg: function(message) {
    var data = this.state.additionalData;
    var newData = data.concat([message]);
    
    console.log(this.setState({additionalData: newData}));
  },

  getMsg: function() {
    var _this = this;

    var curRequest = Parse.Object.extend("Request");
    var reQuery = new Parse.Query(curRequest);
    reQuery.equalTo(
      "objectId", 
      window.location.pathname.substr(window.location.pathname.lastIndexOf('/')+1)
    );
    reQuery.find({
      success: function(data) {
        console.log("receive request query");
        console.log(data);

        _this.setState({requestObj: data[0]});

        var myMsgs = Parse.Object.extend("Message");
        var query = new Parse.Query(myMsgs);
        query.equalTo("request", data[0]);

        query.find({
          success: function(dataMsg) {
            console.log("Successfully retrieved msg: " + dataMsg);
            console.log(dataMsg);

            _this.setState({data: dataMsg});

            try {
              //var channel = requestObject.get("comChannel");
              var channel = data[0].id;

              subscribeToChannel(channel, onMessage);
            } catch(err) {
              console.log("Could not subscribe: " + err);
            }
          },
          error: function(error) {
            alert("Error: " + error.code + " " + error.message);
          }
        });

      },
      error: function(error) {
        alert("Error: " + error.code + " " + error.message);
      }
    });

  },

  componentDidMount: function() {
    this.getMsg();
  },

  handleMsgSubmit: function(newMsg) {
    var Message = Parse.Object.extend("Message");
    var newMessage = new Message();
    newMessage.set("message", newMsg);
    newMessage.set("sender", Parse.User.current().get("username"));
    newMessage.set("request", this.state.requestObj);

    newMessage.save(null, {
      success: function(results) {
        console.log("Successfully saved message");
      },
      error: function(obj, error) {
        console.log("Error saving message: ", error);
      }
    });
  },

  render: function() {
    return (
      <div className="chat-box">
        <MsgList data={this.state.data} additionalData={this.state.additionalData} />
        <ChatForm onMsgSubmit={this.handleMsgSubmit} />
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
    this.props.onMsgSubmit(content);
    this.refs.content.value = '';
  },
  render: function() {
    return (
      <form className="chat-form" onSubmit={this.handleSubmit}>
        <input className="input-text" type="text" placeholder="say something..." ref="content" />
        <input className="send-text" type="submit"/>
      </form>
    );
  }
});

var chatBox = ReactDOM.render(
  <ChatBox />,
  document.getElementsByClassName('right-chat')[0]
);

var updateMsg = function(message) {
  chatBox.addMsg(message);
}

window.updateMsg = updateMsg;
