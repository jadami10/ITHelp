import React, { Component, PropTypes } from 'react';
import { subscribeToChannel } from '../utils/utils';
import pb from '../utils/pubnub'

class Msg extends React.Component {
  constructor(props) {
    super(props);
    this.state = {source: "sent"};
    this.getMsgSource = this.getMsgSource.bind(this);
  }
  
  getMsgSource() {
    if (this.props.source === Parse.User.current().get("username")) {
      this.state.source = "sent";
    } else {
      this.state.source = "received";
    }
  }

  componentWillMount() {
    this.getMsgSource();
  }

  render() {
    return (
      <div className="msg-block">
        <div className={this.state.source + " msg"}>
          {this.props.children}
        </div>
      </div>
    );
  }
};

class MsgList extends React.Component {
  componentDidUpdate(p, s) {
    var chatContentDiv = this.refs.chatContent;
    chatContentDiv.scrollTop = chatContentDiv.scrollHeight;
  }

  render() {
    var msgNodes = this.props.data.map(function(msg, index) {
      return (
        <Msg source={msg.get("sender")} key={index}>
          {msg.get("message")}
        </Msg>
      );
    });

    if (this.props.additionalData) {
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
};

class ChatForm extends React.Component {
  constructor(props) {
    super(props);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(e) {
    e.preventDefault();
    var content = this.refs.content.value.trim();
    if (!content) {
      return;
    }
    this.props.onMsgSubmit(content);
    this.refs.content.value = '';
  }

  render() {
    return (
      <form className="chat-form" onSubmit={this.handleSubmit}>
        <div className="input-text">
          <textarea type="text" placeholder="say something..." rol="3" ref="content"></textarea>
        </div>
        <button className="send-text" type="submit" onClick={this.handleSubmit}>
          <span className="fa fa-send-o"> </span>
        </button>
      </form>
    );
  }
};

class ChatBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      requestObj: [],
      additionalData: [],
      data: []
    };
    this.addMsg = this.addMsg.bind(this);
    this.getMsg = this.getMsg.bind(this);
    this.handleMsgSubmit = this.handleMsgSubmit.bind(this);
  }

  addMsg(message) {
    var data = this.state.additionalData;
    var newData = data.concat([message]);
    
    this.setState({additionalData: newData});
  }

  getMsg() {
    var _this = this;

    var curRequest = Parse.Object.extend("Request");
    var reQuery = new Parse.Query(curRequest);
    reQuery.equalTo(
      "objectId", 
      this.props.params.id
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

            pb.subscribe({
              channel: data[0].id,
              message: function(m){_this.addMsg(m)},
              connect: function() {
                console.log("should be subscribed");
              },
              error: function (error) {
                console.log(JSON.stringify(error));
              }
            });
          },
          error: function(error) {
            console.log("Error: " + error.code + " " + error.message);
          }
        });

      },
      error: function(error) {
        console.log("Error: " + error.code + " " + error.message);
      }
    });

  }

  componentDidMount() {
    this.getMsg();
  }

  handleMsgSubmit(newMsg) {
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
  }

  render() {
    return (
      <div id="chat">
        <div className="chat-box">
          <MsgList data={this.state.data} additionalData={this.state.additionalData} />
          <ChatForm onMsgSubmit={this.handleMsgSubmit} />
        </div>
      </div>
    );
  }
};

export default ChatBox;
