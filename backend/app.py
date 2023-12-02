from flask import Flask, request, jsonify
import hashlib
from os import chdir, path
from sandbox import model, layers, activations, predictions
import sqlite3

chdir(path.dirname(path.abspath(__file__)))
app = Flask(__name__)
model = model.Model(cuda=True)

@app.route('/register', methods=['POST'])
def register():
    # Get username and password
    username = request.form.get('username')
    password = request.form.get('password')

    # Hash password
    hashed_password = hashlib.sha256(password.encode()).hexdigest()

    # Connect to database
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # Check if user already exists
    cursor.execute("SELECT * FROM users WHERE username=?", (username,))
    existing_user = cursor.fetchone()
    if existing_user:
        conn.close()
        return jsonify({'message': 'exists'})

    # Insert new user into the database
    cursor.execute("INSERT INTO users (username, password) VALUES (?, ?)", (username, hashed_password))
    conn.commit()
    conn.close()

    return jsonify({'message': 'User registered successfully'})

@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username')
    password = request.form.get('password')

    # Hash password
    hashed_password = hashlib.sha256(password.encode()).hexdigest()

    # Connect to database
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    # Check whether username and password combination exists
    cursor.execute("SELECT * FROM users WHERE username=? AND password=?", (username, hashed_password))
    user = cursor.fetchone()
    conn.close()
    return jsonify({'message': 'success' if user else 'failure'})

@app.route('/predict', methods=['POST'])
def predict():
    # Get image
    image = request.form.get('image')
    
    # Get model prediction: 1 - Pizza | 0 - Not Pizza
    prediction = model.predict(image, prediction_type=predictions.binary_classification).item()
    return {'prediction': prediction}

if __name__ == '__main__':
    # Set up model
    model.add(layers.Dense(units=32, activation=activations.ReLU()))
    model.add(layers.Dense(units=16, activation=activations.ReLU()))
    model.add(layers.Dense(units=8, activation=activations.ReLU()))
    model.add(layers.Dense(units=1, activation=activations.Sigmoid()))
    
    # Load pre-trained parameters
    model.load(name='parameters.json')

    app.run()
