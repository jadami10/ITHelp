__author__ = 'JA10'

from rest_framework import serializers
from models import USER_TYPES, HELP_TYPES, ITUser, HelpRequest, Message
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'first_name', 'last_name', 'email')

class ITUserSerializer(serializers.Serializer):
    pk = serializers.IntegerField(read_only=True)
    user_data = serializers.ModelField(model_field=User)
    user_type = serializers.ChoiceField(choices=USER_TYPES, required=True)

    def create(self, validated_data):
        """
        Create and return a new `Snippet` instance, given the validated data.
        """
        return ITUser.objects.create(**validated_data)

class HelpSerializer(serializers.Serializer):
     pk = serializers.IntegerField(read_only=True)
     help_type = serializers.ChoiceField(choices=HELP_TYPES, default='NOT SURE')
     requestor = serializers.ModelField(model_field=ITUser)
     open_request = serializers.BooleanField(default=True)

     def create(self, validated_data):
        """
        Create and return a new `Snippet` instance, given the validated data.
        """
        return HelpRequest.objects.create(**validated_data)

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ('create_time', 'sender', 'text')

