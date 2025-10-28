from flask import Flask, session, redirect, url_for, request, render_template_string
from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import Flow
import os
import requests

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev-secret-key')

CLIENT_ID = os.environ.get('GOOGLE_CLIENT_ID')
CLIENT_SECRET = os.environ.get('GOOGLE_CLIENT_SECRET')
REDIRECT_URI = os.environ.get('REDIRECT_URI', 'http://localhost:8080/callback')

HOME_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head><title>GCP SSO Test</title></head>
<body>
    <h1>GCP SSO Authentication Test</h1>
    {% if user %}
        <div>
            <h2>Welcome, {{ user.name }}!</h2>
            <p><strong>Email:</strong> {{ user.email }}</p>
            <p><strong>ID:</strong> {{ user.id }}</p>
            <a href="/logout">Logout</a>
        </div>
    {% else %}
        <a href="/login">Login with Google SSO</a>
    {% endif %}
</body>
</html>
'''

@app.route('/')
def index():
    user = session.get('user')
    return render_template_string(HOME_TEMPLATE, user=user)

@app.route('/login')
def login():
    if not CLIENT_ID or not CLIENT_SECRET:
        return "OAuth credentials not configured. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET environment variables."
    
    flow = Flow.from_client_config(
        {
            "web": {
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "redirect_uris": [REDIRECT_URI]
            }
        },
        scopes=['openid', 'email', 'profile']
    )
    flow.redirect_uri = REDIRECT_URI
    
    authorization_url, state = flow.authorization_url(
        access_type='offline',
        include_granted_scopes='true'
    )
    
    session['state'] = state
    return redirect(authorization_url)

@app.route('/callback')
def callback():
    flow = Flow.from_client_config(
        {
            "web": {
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "redirect_uris": [REDIRECT_URI]
            }
        },
        scopes=['openid', 'email', 'profile'],
        state=session['state']
    )
    flow.redirect_uri = REDIRECT_URI
    
    authorization_response = request.url
    flow.fetch_token(authorization_response=authorization_response)
    
    credentials = flow.credentials
    
    user_info = requests.get(
        'https://www.googleapis.com/oauth2/v2/userinfo',
        headers={'Authorization': f'Bearer {credentials.token}'}
    ).json()
    
    session['user'] = {
        'name': user_info.get('name'),
        'email': user_info.get('email'),
        'id': user_info.get('id')
    }
    
    return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

@app.route('/health')
def health():
    return {'status': 'healthy'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)