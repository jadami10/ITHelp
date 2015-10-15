from flask import Flask, render_template, url_for
import os
app = Flask(__name__)

@app.route('/')
def index(name=None):
    print os.getcwd()
    print url_for('static',filename='css/style.css')
    return render_template('website.html', name=name)

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def page_not_found(e):
    return render_template('404.html'), 500

if __name__ == '__main__':
    app.run()
