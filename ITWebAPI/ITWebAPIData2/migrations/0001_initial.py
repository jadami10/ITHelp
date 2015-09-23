# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='HelpRequest',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('create_time', models.DateTimeField(auto_now_add=True)),
                ('help_type', models.CharField(default=b'NOT_SURE', max_length=100, choices=[(b'WINDOWS', b'WINDOWS'), (b'MAC', b'MAC'), (b'NOT_SURE', b'NOT SURE')])),
                ('open_request', models.BooleanField(default=b'True')),
            ],
        ),
        migrations.CreateModel(
            name='ITUser',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('create_time', models.DateTimeField(auto_now_add=True)),
                ('user_type', models.CharField(default=b'python', max_length=100, choices=[(b'SUPPORT', b'SUPPORT'), (b'NEED', b'NEED'), (b'ADMIN', b'ADMIN')])),
                ('auth_user', models.ForeignKey(to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Message',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('create_time', models.DateTimeField(auto_now_add=True)),
                ('sender', models.CharField(max_length=100)),
                ('receiver', models.CharField(max_length=100)),
                ('text', models.TextField()),
            ],
        ),
        migrations.AddField(
            model_name='helprequest',
            name='need_user',
            field=models.ForeignKey(related_name='need_user', to='ITWebAPIData2.ITUser'),
        ),
        migrations.AddField(
            model_name='helprequest',
            name='support_user',
            field=models.ForeignKey(related_name='support_user', to='ITWebAPIData2.ITUser'),
        ),
    ]
