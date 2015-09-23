__author__ = 'JA10'

from twisted.internet import reactor, protocol, endpoints
from twisted.protocols import basic
import json

class PubProtocol(basic.LineReceiver):
    def __init__(self, factory):
        self.factory = factory
        self.users = {}

    def connectionMade(self):
        self.factory.clients.add(self)

    def connectionLost(self, reason):
        self.factory.clients.remove(self)

    def lineReceived(self, line):
        try:
            data = json.loads(line)
            print data
            for c in self.factory.clients:
                c.sendLine("<{}> {}".format(self.transport.getHost(), line))
        except:
            print 'LINE:'
            print line



class PubFactory(protocol.Factory):
    def __init__(self):
        self.clients = set()

    def buildProtocol(self, addr):
        return PubProtocol(self)

endpoints.serverFromString(reactor, "tcp:1025").listen(PubFactory())
reactor.run()