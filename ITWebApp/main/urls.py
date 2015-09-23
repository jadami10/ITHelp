__author__ = 'JA10'

import views
from django.conf.urls import url

urlpatterns = [
    url(r'^$', views.home),
    url(r'^js/', views.home),
    url(r'^messaging/', views.MessageList.as_view())
]