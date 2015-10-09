from twisted.web import server, resource
from twisted.internet import reactor, endpoints
import json

class Counter(resource.Resource):
    isLeaf = True
    numberRequests = 0

    def render_GET(self, request):
        self.numberRequests += 1
        request.setHeader("content-type", "text/plain")
        return "I am request #" + str(self.numberRequests) + "\n"

    def render_POST(self, request):
        try:
            data = json.loads(request)
            print data
        except:
            print 'Line:\n'
            print request
        print 'here'
        return request

endpoints.serverFromString(reactor, "tcp:8080").listen(server.Site(Counter()))
reactor.run()