import mockery from 'mockery';
import sinon from 'sinon';
import should from 'should';

describe('#utils functions', function () {

  beforeEach(() => {
    mockery.enable();
  });

  afterEach(() => {
    mockery.deregisterAll();
    mockery.disable();
  });

  it('subscribeToChannel: subscribe should be called', function() {
    var spy = sinon.spy();
    mockery.registerMock('../utils/pubnub', { subscribe: spy });
    const subscribeToChannel = require('../public/src/scripts/utils/utils').subscribeToChannel;
    subscribeToChannel({}, null);
    spy.called.should.equal.true;
  });

  it('subscribeToChat: subscribe should be called', function() {
    var spy = sinon.spy();
    mockery.registerMock('../utils/pubnub', { subscribe: spy });
    const subscribeToChat = require('../public/src/scripts/utils/utils').subscribeToChat;
    subscribeToChat({id:{}}, null);
    spy.called.should.equal.true;
  });

  it('subscribeToUser: subscribe should be called', function() {
    var spy = sinon.spy();
    mockery.registerMock('../utils/pubnub', { subscribe: spy });
    const subscribeToUser = require('../public/src/scripts/utils/utils').subscribeToUser;
    subscribeToUser({}, null);
    spy.called.should.equal.true;
  });

});
