#!/bin/bash

# Update system
apt-get update
apt-get install -y python3 python3-pip nginx

# Create app directory
mkdir -p /opt/sso-app
cd /opt/sso-app

# Copy app files
cat > app.py << 'EOF'
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
EOF

# Install Python dependencies
pip3 install Flask==2.3.3 google-auth==2.23.4 google-auth-oauthlib==1.1.0 requests==2.31.0

# Create systemd service
cat > /etc/systemd/system/sso-app.service << 'EOF'
[Unit]
Description=SSO Flask App
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/sso-app
ExecStart=/usr/bin/python3 /opt/sso-app/app.py
Restart=always
Environment="SECRET_KEY=production-secret-key"

[Install]
WantedBy=multi-user.target
EOF

# Configure Nginx
cat > /etc/nginx/sites-available/sso-app << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Set permissions
chown -R www-data:www-data /opt/sso-app
chmod +x /opt/sso-app/app.py

# Enable services
ln -s /etc/nginx/sites-available/sso-app /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

systemctl daemon-reload
systemctl enable sso-app
systemctl start sso-app
systemctl restart nginx