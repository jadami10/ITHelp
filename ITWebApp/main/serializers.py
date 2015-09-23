__author__ = 'JA10'

from rest_framework import serializers
from models import Message
from django.contrib.auth.models import User

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ('create_time', 'sender', 'text')