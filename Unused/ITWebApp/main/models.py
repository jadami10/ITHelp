from django.db import models

# Create your models here.

class Message(models.Model):
    create_time = models.DateTimeField(auto_now_add=True)
    #sender = models.ForeignKey(ITUser, related_name='sender')
    #receiver = models.ForeignKey(ITUser, related_name='receiver')
    sender = models.CharField(max_length=100)
    receiver = models.CharField(max_length=100)
    text = models.TextField()