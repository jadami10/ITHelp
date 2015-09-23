from django.shortcuts import render
from django.http import HttpResponse
from rest_framework.renderers import JSONRenderer
from rest_framework.parsers import JSONParser
from models import Message
from rest_framework.views import APIView
from serializers import *

# Create your views here.

class JSONResponse(HttpResponse):
    """
    An HttpResponse that renders its content into JSON.
    """
    def __init__(self, data, **kwargs):
        content = JSONRenderer().render(data)
        kwargs["content_type"] = "application/json"
        super(JSONResponse, self).__init__(content, **kwargs)



def home(request):
    return render(request, "main/simple/home.html")

class MessageList(APIView):

    def get(self, request, format=None):
        msgs = Message.objects.all()
        serializer = MessageSerializer(msgs, many=True)
        return JSONResponse(serializer.data)

    def post(self, request, format=None):

        if request.method == 'POST':
            data = JSONParser().parse(request)
            serializer = MessageSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                return JSONResponse(serializer.data, status=201)
            return JSONResponse(serializer.errors, status=400)