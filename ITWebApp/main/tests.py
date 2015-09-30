from django.test import TestCase, Client
import json

# Create your tests here.

class SimpleTest(TestCase):

    def setUp(self):

        self.client = Client()

    def simple_test(self):

        x = 5
        self.assertEqual(x, 5)

    def test_home(self):
        # Issue a GET request.
        response = self.client.get('/home/')

        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 200)

    def test_bad_url(self):
        # Issue a GET request.
        response = self.client.get('/home/messaging')

        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 301)

    def test_get_messages(self):
        # Issue a GET request.
        response = self.client.get('/home/messaging/')

        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 200)

    def test_post_bad_messages(self):
        # Issue a POST request.
        response = self.client.post('/home/messaging/', {'text': 'hi', 'senders': 'johan'})
        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 400)

        # Issue a POST request.
        response = self.client.post('/home/messaging/', {'text': 'hi!', 'senders': 'maria'})
        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 400)

    def test_post_messages(self):

        # Issue a POST request.
        my_data = json.dumps({'text': 'hi', 'sender': 'johan'})
        response = self.client.post('/home/messaging/', my_data,  content_type='application/json')
        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 201)

        # Issue a POST request.
        my_data = json.dumps({'text': 'hi to you', 'sender': 'maria'})
        response = self.client.post('/home/messaging/', my_data,  content_type='application/json')
        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 201)

    def test_get_created_messages(self):

        # Issue a GET request.
        response = self.client.get('/home/messaging/')

        # Check that the response is 200 OK.
        self.assertEqual(response.status_code, 200)


        # Check you get back 2 messages
        self.assertEqual(len(response.content), 2)

