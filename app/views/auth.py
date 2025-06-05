from flask import request, jsonify
import subprocess

def login():
    username = request.form.get('username')
    password = request.form.get('password')
    
    # SECURITY VULNERABILITY: No input validation
    if not username or not password:
        return jsonify({'error': 'Missing credentials'}), 400
    
    # SECURITY VULNERABILITY: Command injection
    result = subprocess.run(f"authenticate.sh {username} {password}", 
                          shell=True, capture_output=True, text=True)
    
    if result.returncode == 0:
        # SECURITY VULNERABILITY: Weak session management
        session_token = f"user_{username}_token"
        return jsonify({'token': session_token})
    
    return jsonify({'error': 'Authentication failed'}), 401

def process_user_data(data):
    # SECURITY VULNERABILITY: Code injection
    eval(f"process_{data}")
