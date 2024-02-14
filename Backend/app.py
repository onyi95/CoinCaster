from flask import Flask, request, jsonify, session
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_apscheduler import APScheduler
import requests
import jwt
import time
import boto3
import os
from apns2.client import APNsClient
from apns2.payload import Payload
from apns2.credentials import TokenCredentials
from werkzeug.security import generate_password_hash, check_password_hash
from itsdangerous import URLSafeTimedSerializer
from flask_mail import Mail, Message
import logging
import collections



app = Flask(__name__)

logging.basicConfig(level=logging.INFO)

# Configure the SQLAlchemy part of the app instance
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = os.environ.get('SECRET_KEY', 'defaultsecrettkey')
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USERNAME'] = os.environ.get('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.environ.get('MAIL_PASSWORD')
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USE_SSL'] = False
# Added flask_mail for use later to create password reset endpoint

# Creating the SQLAlchemy db instance
db = SQLAlchemy(app)

migrate = Migrate(app, db)

mail = Mail(app)
s = URLSafeTimedSerializer(app.secret_key)

def download_p8_from_s3():
    s3_client = boto3.client(
        's3',
        aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY'),
        region_name=os.environ.get('AWS_DEFAULT_REGION')
    )
    
    bucket_name = os.environ.get('S3_BUCKET_NAME')
    p8_file_path = os.environ.get('P8_FILE_PATH')
    local_file_name = 'AuthKey.p8'
    local_file_path = '/tmp/AuthKey.p8'
    
    s3_client.download_file(bucket_name, p8_file_path, local_file_path)
    print(f"{local_file_name} downloaded from S3 bucket {bucket_name}")
    return local_file_path
  
# Define the User model
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    apns_token = db.Column(db.String(200), nullable=True)
    target_price = db.Column(db.Float, nullable=True)
    selected_currency = db.Column(db.String(10), nullable=True)
    notification_sent = db.Column(db.Boolean, default=False, nullable=False)
    
# Initialize the database and create tables
@app.before_request
def create_tables():
    db.create_all()

# API endpoint for registering a new user
@app.route('/register_user', methods=['POST'])
def register():
    data = request.json
    print(f"Incoming request data: {data}")
    email = data['email']
    password = data['password']
    
# check if email aleady exists
    user_exists = User.query.filter_by(email=email).first()
    if user_exists:
        return jsonify({'message': 'Email already registered'}), 409
    
    hashed_password = generate_password_hash(password)
    
    new_user = User(email=email, password_hash=hashed_password)
    db.session.add(new_user)
    
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({'message': 'Email already registered'}), 409

    return jsonify({'user_id': new_user.id}), 201

# API endpoint for user login
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()

    if user and check_password_hash(user.password_hash, password):
        # Create user session
        session['user_id'] = user.id
        return jsonify({'message': 'Login successful', 'user_id': user.id}), 200
    else:
        return jsonify({'message': 'Invalid email or password'}), 401

# API endpoint to recieve and store user device tokens after the user has registered
@app.route('/register_token', methods=['POST'])
def register_token():
    data = request.json
    id = data.get('user_id')
    token = data.get('token')

    user = User.query.filter_by(id=id).first()
    if user:
        user.apns_token = token
        db.session.commit()
        return jsonify({'message': 'Token registered successfully!'}), 200
    else:
        return jsonify({'message': 'User not found'}), 404

# API endpoint for updating a user's alert threshold
@app.route('/update_alert', methods=['POST'])
def update_target_price():
    data = request.json
    id = data.get('user_id')
    new_target_price = float(data.get('target_price'))

    user = User.query.filter_by(id=id).first()
    if user:
        user.target_price = new_target_price
        user.notification_sent = False
        db.session.commit()
        return jsonify({'message': 'Target price updated successfully'}), 200
    else:
        return jsonify({'message': 'User not found'}), 404

# API endpoint for user logout
@app.route('/logout', methods=['POST'])
def logout():
    # Retrieve user ID from the request
    data = request.json
    id = data.get('user_id')
    
    user = User.query.filter_by(id=id).first()

    if user:
        # Disassociate the APNs token from the user
        user.apns_token = None
        db.session.commit()
        return jsonify({'message': 'Logged out successfully'}), 200
    else:
        return jsonify({'message': 'User not found'}), 404

# API endpoint to recieve user selected currency for use in the API calls
@app.route('/selected_currency', methods=['POST'])
def selected_currency():
    data = request.json
    id = data.get('user_id')
    selected_currency = data.get('selected_currency')
    
    user = User.query.filter_by(id=id).first()
    if user:
        user.selected_currency = selected_currency
        db.session.commit()
        return jsonify({'message': 'Selected currency updated successfully!'}), 200
    else:
        return jsonify({'message': 'User not found'}), 404

def get_bitcoin_price(currency="USD"): # Default to USD if not specified
    coinapi_key = os.environ.get('COINAPI_KEY')
    if not coinapi_key:
        logging.info("Error: CoinAPI key is missing.")
        return None  # Indicate an error condition

    try:
        url = f"https://rest.coinapi.io/v1/exchangerate/BTC/{currency}"
        response = requests.get(url, headers={"X-CoinAPI-Key": coinapi_key})

        if response.status_code == 200:
            data = response.json()
            # Now directly access 'rate' in the data dictionary
            rate = data.get('rate', None)
            if rate is not None:
                return rate
            else:
                logging.info("Error: 'rate' not found in the response.")
        else:
            logging.info(f"Error: Failed to fetch data. Status code: {response.status_code}")
    except requests.RequestException as e:
        logging.info(f"Error: An error occurred while fetching data. {e}")
    return None # Indicate an error condition if any of the above fails

@app.route('/bitcoin_price')
def bitcoin_price():
    price = get_bitcoin_price()
    return f"The current Bitcoin price is: ${price}"

Notification = collections.namedtuple('Notification',['token', 'payload'])

def check_price_and_alert_users():
    with app.app_context():
        # First, check if there are any users to alert
        users_to_alert = User.query.filter(User.target_price.isnot(None), User.notification_sent == False).all()
        
        # If there are users to alert, then fetch the current Bitcoin price
        if users_to_alert:
            for user in users_to_alert:
                current_price = get_bitcoin_price(user.selected_currency)   # Fetch price in user's selected currency
                if isinstance(current_price, float):  # Ensuring current_price is a valid float
                    formatted_price = "{:.2f}".format(current_price)  # Format price to two decimal places
                    print(f"The current Bitcoin price is: {user.selected_currency} {current_price}")
                    # Check if the current price has reached the target price
                    if user.target_price <= current_price:
                        token = user.apns_token
                        if token:
                            payload = Payload(alert=f"Bitcoin price reached {user.selected_currency} {formatted_price}", sound="default", badge=1)
                            notifications = [Notification(token=token, payload=payload)]
                            user.notification_sent = True  # Marking notification as sent
                            user.selected_currency = None  # Clearing the selected currency as user may select a different one in future
                            db.session.commit()  # Commit changes after processing user
                            logging.info(f"Attempting to send push notification to token: {token}")
                            send_push_notifications_batch(notifications)
                else:
                    print(f"Current price is None or invalid for currency {user.selected_currency}, skipping user alert check.")
        else:
            print("No users with set targets or already notified.")

# Add scheduler
scheduler = APScheduler()
scheduler.init_app(app)
scheduler.start()
     
scheduler.add_job(id='check_price_job', func=check_price_and_alert_users, trigger='interval', minutes=2)

def send_push_notifications_batch(notifications):
    # First, .p8 file is downloaded from S3
    auth_key_path = download_p8_from_s3()
    
    # Environment variables
    auth_key_id = os.environ.get("APNS_KEY_ID")
    team_id = os.environ.get("APNS_TEAM_ID")
    
    # Use the downloaded .p8 file for token generation
    token_credentials = TokenCredentials(auth_key_path=auth_key_path, auth_key_id=auth_key_id, team_id=team_id)
    client = APNsClient(credentials=token_credentials, use_sandbox=True)
    
    try:
        response = client.send_notification_batch(notifications=notifications, topic='com.onyiesu.coincaster')
        # Log the response from APNs
        logging.info(f"Notification sent. Response: {response}")
    except Exception as e:
        # Log any exceptions that occur
        logging.error(f"Error sending push notification: {e}")
        
@app.route('/')
def root():
    return 'Bitcoin price alert app!'

if __name__ == '__main__':
    port = int(os.environ.get("PORT",5000))
    app.run(host='0.0.0.0', port=port, debug=True)

