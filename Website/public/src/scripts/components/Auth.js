import React, { Component, PropTypes } from 'react';
import LoginForm from './LoginForm';

const loginForm = React.createElement(LoginForm);

class Auth extends React.Component {
  render() {
    return (
      <div id="login">
        <div className="wrapper">
          <div className="login">
            <img src="/assets/logo.png" />
            <div className="login-form">
              {loginForm}
            </div>
          </div>
        </div >
      </div>
    )
  }
};

export default Auth;
