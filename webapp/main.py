from mimetypes import MimeTypes

import logging
import os
import cloudstorage as gcs
import webapp2

from google.appengine.api import app_identity

from flask import Flask, request, jsonify, send_file, Response
app = Flask(__name__)
app.config['DEBUG'] = True

from werkzeug.utils import secure_filename

# Note: We don't need to call run() since our application is embedded within
# the App Engine WSGI application server.

# TODO: till have to change this list depending on what files we allow
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])

#[START retries]
my_default_retry_params = gcs.RetryParams(initial_delay=0.2,
                      max_delay=5.0,
                      backoff_factor=2,
                      max_retry_period=15)
gcs.set_default_retry_params(my_default_retry_params)
#[END retries]

@app.route('/')
def hello():
  """Return a friendly HTTP greeting."""
  return 'Hello World! cvwang suppo v1.0'


@app.errorhandler(404)
def page_not_found(e):
  """Return a custom 404 error."""
  return 'Sorry, nothing at this URL.', 404


@app.route('/upload', methods=['POST'])
def upload():
  if request.method == 'POST':
    file = request.files['file']
    extension = secure_filename(file.filename).rsplit('.', 1)[1]
    options = {}
    options['retry_params'] = gcs.RetryParams(backoff_factor=1.1)
    # TODO: maybe get mimetype from rqeuest metadata
    options['content_type'] = 'image/' + extension
    path = to_bucket(str(secure_filename(file.filename)))
    if file and allowed_file(file.filename):
      try:
        with gcs.open(path, 'w', **options) as f:
          f.write(file.stream.read()) # instead of f.write(str(file))
          print jsonify({"success": True})
        return jsonify({"success": True})
      except Exception as e:
        logging.exception(e)
        return jsonify({"success": False})


@app.route('/download/<path:filename>', methods=['GET'])
def download(filename):
  if request.method == 'GET':
    def generate():
      gcs_file = gcs.open(to_bucket(filename)) # read file
      yield gcs_file.read()
    # TODO: this may not be a fullproof way to get the mimetype
    mimetype_guess = MimeTypes().guess_type(filename)
    return Response(generate(), mimetype=mimetype_guess[0])
  

def allowed_file(filename):
  return '.' in filename and \
     filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

def to_bucket(filename):
  bucket_name = "dexapp-2016.appspot.com"
  return '/' + bucket_name + '/' + str(secure_filename(filename))
