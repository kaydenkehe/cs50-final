import cv2
from flask import Flask, request, jsonify
import hashlib
import cupy as np
from os import chdir, path
from sandbox import model, layers, activations, predictions
import sqlite3

chdir(path.dirname(path.abspath(__file__)))
app = Flask(__name__)
model = model.Model(cuda=True)

@app.route('/test')
def test():
    return 'success'

@app.route('/register', methods=['POST'])
def register():
    # Get username and password
    content = request.get_json()
    username = content['username']
    password = content['password']
    email = content['email']

    # Hash password
    hashed_password = hashlib.sha256(password.encode()).hexdigest()

    # Connect to database
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # Check if user already exists
    cursor.execute('SELECT * FROM users WHERE username=?', (username,))
    existing_user = cursor.fetchone()
    if existing_user:
        conn.close()
        return jsonify({'message': 'exists'})

    # Insert new user into the database
    cursor.execute('INSERT INTO users (username, password, email) VALUES (?, ?, ?)', (username, hashed_password, email))
    conn.commit()
    conn.close()

    return jsonify({'message': 'success'})

@app.route('/login', methods=['POST'])
def login():
    content = request.get_json()
    username = content['username']
    password = content['password']

    # Hash password
    hashed_password = hashlib.sha256(password.encode()).hexdigest()

    # Connect to database
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # Check whether username and password combination exists
    cursor.execute('SELECT * FROM users WHERE username=? AND password=?', (username, hashed_password))
    user = cursor.fetchone()
    conn.close()
    return jsonify({'message': 'success' if user else 'failure'})

@app.route('/predict', methods=['POST'])
def predict():
    image = request.get_json()['image'] # Get image
    image = np.uint8(image).reshape((320, 240, 3)) # Reshape flattened image
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR) # Convert image from RGB to BGR 
    image = image[40:280][:][:] # Crop image to 1:1 aspect ratio
    image = cv2.resize(image, (64, 64)) # Resize to uniform dimension
    image = image.flatten() # Flatten image matrix into vector
    image = np.asarray(image) / 255 # Normalize values, convert NumPy array to CuPy array
    image = image.reshape((1, image.shape[0])) # Reshape image matrix

    # Get model prediction: 1 - Pizza | 0 - Not Pizza
    prediction = model.predict(image, prediction_type=predictions.binary_classification).item()
    return jsonify({'prediction': prediction})

if __name__ == '__main__':
    # Set up model
    model.add(layers.Dense(units=32, activation=activations.ReLU()))
    model.add(layers.Dense(units=16, activation=activations.ReLU()))
    model.add(layers.Dense(units=8, activation=activations.ReLU()))
    model.add(layers.Dense(units=1, activation=activations.Sigmoid()))
    
    # Load pre-trained parameters
    model.load(name='parameters.json')

    app.run(debug=True, host='0.0.0.0', port=12999)
