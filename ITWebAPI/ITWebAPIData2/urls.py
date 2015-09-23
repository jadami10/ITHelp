__author__ = 'JA10'

from django.conf.urls import url

import views

urlpatterns = [
    #url(r'^admin/', include(admin.site.urls)),
    #url(r'^', include('ITWebAPIData2.urls')),
    url(r'^users/', views.ITUserList.as_view()),
    url(r'^users/(?P<pk>[0-9]+)/$', views.ITUserList.as_view()),
    url(r'messaging/', views.MessageList.as_view())
]