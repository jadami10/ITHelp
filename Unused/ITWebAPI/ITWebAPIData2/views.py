from django.shortcuts import render
from django.http import HttpResponse
from rest_framework.renderers import JSONRenderer
from rest_framework.parsers import JSONParser
from models import ITUser, HelpRequest, Message
from rest_framework.views import APIView
from rest_framework import status
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt

from serializers import  *

# Create your views here.


class JSONResponse(HttpResponse):
    """
    An HttpResponse that renders its content into JSON.
    """
    def __init__(self, data, **kwargs):
        content = JSONRenderer().render(data)
        kwargs["content_type"] = "application/json"
        super(JSONResponse, self).__init__(content, **kwargs)

class ITUserList(APIView):
    """
    List all users, or create a new user.
    """
    def get(self, request, format=None):
        users = ITUser.objects.all()
        serializer = ITUserSerializer(users, many=True)
        return JSONResponse(serializer.data)

    def post(self, request, format=None):
        serializer = ITUserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return JSONResponse(serializer.data, status=status.HTTP_201_CREATED)
        return JSONResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    #def delete(self, request, pk, format=None):
    #    user = self.get_object(pk)
    #    user.delete()
    #    return JSONResponse(status=status.HTTP_204_NO_CONTENT)

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

def user_list(request):
    """
    List all users.
    """
    if request.method == 'GET':
        users = ITUser.objects.all()
        serializer = UserSerializer(users, many=True)
        return JSONResponse(serializer.data)

def request_list(request):
    """
    List all requests, or create a new user.
    """
    if request.method == 'GET':
        reqs = HelpRequest.objects.all()
        serializer = HelpSerializer(reqs, many=True)
        return JSONResponse(serializer.data)

def user_detail(request, pk):
    """
    Retrieve, update or delete a code snippet.
    """
    try:
        it_user = ITUser.objects.get(pk=pk)
    except ITUser.DoesNotExist:
        return HttpResponse(status=404)

    if request.method == 'GET':
        serializer = UserSerializer(it_user)
        return JSONResponse(serializer.data)

def request_detail(request, pk):
    """
    Retrieve, update or delete a code snippet.
    """
    try:
        request_detail = HelpRequest.objects.get(pk=pk)
    except HelpRequest.DoesNotExist:
        return HttpResponse(status=404)

    if request.method == 'GET':
        serializer = UserSerializer(request_detail())
        return JSONResponse(serializer.data)

@method_decorator(csrf_exempt)
def messaging(request):

    if request.method == 'POST':
        data = JSONParser().parse(request)
        serializer = MessageSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JSONResponse(serializer.data, status=201)
        return JSONResponse(serializer.errors, status=400)