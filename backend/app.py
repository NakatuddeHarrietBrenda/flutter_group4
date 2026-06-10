import os
import sqlite3
import hashlib
import uuid
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes so Flutter web doesn't get blocked.

DB_FILE = 'nutriblend.db'

def get_db_connection():
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def hash_password(password):
    return hashlib.sha256(password.encode('utf-8')).hexdigest()

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Create Users table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL
        )
    ''')
    
    # Create Orders table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT,
            customer_phone TEXT,
            delivery_method TEXT,
            delivery_region_id INTEGER,
            delivery_town_id INTEGER,
            delivery_address TEXT,
            total_amount REAL,
            items_json TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Create Sessions table to store mock session tokens
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS sessions (
            token TEXT PRIMARY KEY,
            user_id INTEGER,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    conn.commit()
    conn.close()

# Initialize DB structure
init_db()

# Mock Products list matching Product.fromJson expected structure
MOCK_PRODUCTS = [
    {
        "id": 1,
        "name": "Rouge Elixir Premium",
        "sku": "NBH-ROU-001",
        "price": 380000.0,
        "formatted_price": "UGX 380,000",
        "wholesale_price": 300000.0,
        "stock_quantity": 12,
        "in_stock": True,
        "main_image": "https://images.unsplash.com/photo-1547887537-6158d64c35b3?w=500",
        "category": {"id": 1, "name": "Rouge"},
        "brand": {"id": 1, "name": "NutriBlend Elixir"}
    },
    {
        "id": 2,
        "name": "Imperial Oud Absolute",
        "sku": "NBH-OUD-002",
        "price": 450000.0,
        "formatted_price": "UGX 450,000",
        "wholesale_price": 360000.0,
        "stock_quantity": 8,
        "in_stock": True,
        "main_image": "https://images.unsplash.com/photo-1594035910387-fea47794261f?w=500",
        "category": {"id": 2, "name": "Oud"},
        "brand": {"id": 1, "name": "NutriBlend Elixir"}
    },
    {
        "id": 3,
        "name": "Aqua Sport Intense",
        "sku": "NBH-AQU-003",
        "price": 290000.0,
        "formatted_price": "UGX 290,000",
        "wholesale_price": 220000.0,
        "stock_quantity": 20,
        "in_stock": True,
        "main_image": "https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=500",
        "category": {"id": 3, "name": "Aqua"},
        "brand": {"id": 2, "name": "NutriBlend Sport"}
    },
    {
        "id": 4,
        "name": "Velvet Rouge Luxury",
        "sku": "NBH-ROU-004",
        "price": 320000.0,
        "formatted_price": "UGX 320,000",
        "wholesale_price": 250000.0,
        "stock_quantity": 15,
        "in_stock": True,
        "main_image": "https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=500",
        "category": {"id": 1, "name": "Rouge"},
        "brand": {"id": 1, "name": "NutriBlend Elixir"}
    },
    {
        "id": 5,
        "name": "Midnight Noir Mystique",
        "sku": "NBH-BLK-005",
        "price": 410000.0,
        "formatted_price": "UGX 410,000",
        "wholesale_price": 330000.0,
        "stock_quantity": 5,
        "in_stock": True,
        "main_image": "https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?w=500",
        "category": {"id": 4, "name": "Black"},
        "brand": {"id": 1, "name": "NutriBlend Elixir"}
    },
    {
        "id": 6,
        "name": "Royal Arabic Oud",
        "sku": "NBH-OUD-006",
        "price": 480000.0,
        "formatted_price": "UGX 480,000",
        "wholesale_price": 390000.0,
        "stock_quantity": 0,
        "in_stock": False,
        "main_image": "https://images.unsplash.com/photo-1588405748373-122b2321bc31?w=500",
        "category": {"id": 2, "name": "Oud"},
        "brand": {"id": 1, "name": "NutriBlend Elixir"}
    }
]

# Mock Regions & Towns data
MOCK_REGIONS = [
    {"id": 1, "name": "Central Region"},
    {"id": 2, "name": "Western Region"},
    {"id": 3, "name": "Eastern Region"},
    {"id": 4, "name": "Northern Region"}
]

MOCK_TOWNS = {
    1: [
        {"id": 101, "name": "Kampala"},
        {"id": 102, "name": "Entebbe"},
        {"id": 103, "name": "Mukono"}
    ],
    2: [
        {"id": 201, "name": "Mbarara"},
        {"id": 202, "name": "Fort Portal"},
        {"id": 203, "name": "Kabale"}
    ],
    3: [
        {"id": 301, "name": "Jinja"},
        {"id": 302, "name": "Mbale"},
        {"id": 303, "name": "Tororo"}
    ],
    4: [
        {"id": 401, "name": "Gulu"},
        {"id": 402, "name": "Lira"},
        {"id": 403, "name": "Arua"}
    ]
}

# --- ENDPOINTS ---

@app.route('/api/v1/auth/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    
    if not name or not email or not password:
        return jsonify({"message": "All fields (name, email, password) are required."}), 422
        
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Check if user already exists
    cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
    if cursor.fetchone():
        conn.close()
        return jsonify({"message": "An account with this email already exists."}), 409
        
    # Create new user
    pwd_hash = hash_password(password)
    try:
        cursor.execute(
            "INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)",
            (name, email, pwd_hash)
        )
        user_id = cursor.lastrowid
        
        # Generate token
        token = str(uuid.uuid4())
        cursor.execute("INSERT INTO sessions (token, user_id) VALUES (?, ?)", (token, user_id))
        conn.commit()
        
        response_data = {
            "token": token,
            "data": {
                "token": token,
                "name": name,
                "email": email
            }
        }
        conn.close()
        return jsonify(response_data), 201
        
    except Exception as e:
        conn.close()
        return jsonify({"message": f"Database error: {str(e)}"}), 500

@app.route('/api/v1/auth/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({"message": "Email and password are required."}), 422
        
    conn = get_db_connection()
    cursor = conn.cursor()
    
    pwd_hash = hash_password(password)
    cursor.execute("SELECT id, name, email FROM users WHERE email = ? AND password_hash = ?", (email, pwd_hash))
    user = cursor.fetchone()
    
    if not user:
        conn.close()
        return jsonify({"message": "Invalid email/phone or password. Please try again."}), 401
        
    # Generate token
    token = str(uuid.uuid4())
    cursor.execute("INSERT INTO sessions (token, user_id) VALUES (?, ?)", (token, user['id']))
    conn.commit()
    
    response_data = {
        "token": token,
        "data": {
            "token": token,
            "name": user['name'],
            "email": user['email']
        }
    }
    conn.close()
    return jsonify(response_data), 200

@app.route('/api/v1/products', methods=['GET'])
def get_products():
    page = request.args.get('page', default=1, type=int)
    # We serve all products as page 1 to make it easy
    return jsonify({
        "data": MOCK_PRODUCTS,
        "meta": {
            "current_page": page,
            "last_page": 1,
            "total": len(MOCK_PRODUCTS)
        }
    }), 200

@app.route('/api/v1/regions', methods=['GET'])
def get_regions():
    return jsonify({
        "data": MOCK_REGIONS
    }), 200

@app.route('/api/v1/regions/<int:region_id>/towns', methods=['GET'])
def get_towns(region_id):
    towns = MOCK_TOWNS.get(region_id, [])
    return jsonify({
        "data": towns
    }), 200

@app.route('/api/v1/orders', methods=['POST'])
def place_order():
    # Verify Authorization header if present
    auth_header = request.headers.get('Authorization', '')
    token = None
    if auth_header.startswith('Bearer '):
        token = auth_header.split(' ')[1]
        
    # Let's verify token in DB
    user_id = None
    if token:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT user_id FROM sessions WHERE token = ?", (token,))
        row = cursor.fetchone()
        if row:
            user_id = row['user_id']
        conn.close()

    # Note: Even if auth token is missing or invalid, we will allow checkout
    # but print warning, as the client might submit order under guest or simulate it.
    data = request.get_json() or {}
    
    # Store order to database
    import json
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('''
            INSERT INTO orders (
                customer_name, customer_phone, delivery_method,
                delivery_region_id, delivery_town_id, delivery_address,
                total_amount, items_json
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            data.get('customer_name'),
            data.get('customer_phone'),
            data.get('delivery_method'),
            data.get('delivery_region_id'),
            data.get('delivery_town_id'),
            data.get('delivery_address') or data.get('shipping_address'),
            data.get('total_amount') or 0.0,
            json.dumps(data.get('items'))
        ))
        conn.commit()
        order_id = cursor.lastrowid
        conn.close()
        
        return jsonify({
            "message": "Order placed successfully.",
            "data": {
                "order_id": order_id,
                "status": "pending"
            }
        }), 201
    except Exception as e:
        if conn:
            conn.close()
        return jsonify({"message": f"Failed to record order: {str(e)}"}), 500

if __name__ == '__main__':
    # Start on port 5000, bind to 0.0.0.0 so external/local devices can connect
    app.run(host='0.0.0.0', port=5000, debug=True)
