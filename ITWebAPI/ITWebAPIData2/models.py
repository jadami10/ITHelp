from django.db import models

# Create your models here.

USER_TYPES = [('SUPPORT','SUPPORT'), ('NEED','NEED'), ('ADMIN','ADMIN')]
HELP_TYPES = [('WINDOWS','WINDOWS'), ('MAC','MAC'), ('NOT_SURE','NOT SURE')]

class ITUser(models.Model):
    create_time = models.DateTimeField(auto_now_add=True)
    auth_user = models.ForeignKey('auth.User')
    user_type = models.CharField(choices=USER_TYPES, default='python', max_length=100)

class HelpRequest(models.Model):
    create_time = models.DateTimeField(auto_now_add=True)
    help_type = models.CharField(choices=HELP_TYPES, default='NOT_SURE', max_length=100)
    support_user = models.ForeignKey(ITUser, related_name='support_user')
    need_user = models.ForeignKey(ITUser, related_name='need_user')
    open_request = models.BooleanField(default='True')

class Message(models.Model):
    create_time = models.DateTimeField(auto_now_add=True)
    #sender = models.ForeignKey(ITUser, related_name='sender')
    #receiver = models.ForeignKey(ITUser, related_name='receiver')
    sender = models.CharField(max_length=100)
    receiver = models.CharField(max_length=100)
    text = models.TextField()