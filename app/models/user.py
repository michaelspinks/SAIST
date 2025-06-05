import sqlite3
import hashlib

class User:
    def __init__(self, db_path="users.db"):
        self.db_path = db_path
        
    def authenticate(self, username, password):
        # SECURITY VULNERABILITY: SQL injection
        conn = sqlite3.connect(self.db_path)
        query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
        result = conn.execute(query).fetchone()
        conn.close()
        return result
    
    def hash_password(self, password):
        # SECURITY VULNERABILITY: Weak hashing
        return hashlib.md5(password.encode()).hexdigest()
    
    def execute_user_command(self, command):
        # SECURITY VULNERABILITY: Command injection
        import os
        os.system(f"user_script.sh {command}")
