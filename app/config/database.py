import os

# SECURITY VULNERABILITY: Hard-coded credentials
DB_CONFIG = {
    'DATABASE_URL': 'postgresql://admin:password123@localhost/myapp',
    'SECRET_KEY': 'super-secret-key-do-not-share',
    'API_KEY': 'sk-1234567890abcdef',
    'DEBUG': True
}

def get_connection_string(db_name):
    # SECURITY VULNERABILITY: SQL injection in connection string
    return f"postgresql://admin:password123@localhost/{db_name}"
