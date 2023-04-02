from flask import Flask, jsonify, request
from flask_mysqldb import MySQL

app = Flask(__name__)
# app.config['MYSQL_HOST'] = "0.0.0.0"
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'password'
app.config['MYSQL_DB'] = 'Vehicles'
app.config['MYSQL_PORT'] = 3306
# app.config['MYSQL_CURSORCLASS'] = 'DictCursor'
mysql = MySQL(app)

@app.route('/customers', methods=['POST'])
def add_customer():
    cur = mysql.connection.cursor()
    first_name = request.json['first_name']
    last_name = request.json['last_name']
    email = request.json.get('email')
    phone_number = request.json['phone_number']
    cur.execute("INSERT INTO Customers (First_name, Last_name, Email, Phone_Number) VALUES (%s, %s, %s, %s)", (first_name, last_name, email, phone_number))
    mysql.connection.commit()
    cur.close()
    return jsonify({'message': 'Customer added successfully'})

@app.route('/customers/<int:id>', methods=['PUT'])
def update_customer(id):
    cur = mysql.connection.cursor()
    first_name = request.json.get('first_name')
    last_name = request.json.get('last_name')
    email = request.json.get('email')
    phone_number = request.json.get('phone_number')
    query = "UPDATE Customers SET"
    if first_name:
        query += " First_name = %s,"
    if last_name:
        query += " Last_name = %s,"
    if email:
        query += " Email = %s,"
    if phone_number:
        query += " Phone_Number = %s,"
    query = query.rstrip(',') + " WHERE Customer_ID = %s"
    cur.execute(query, (first_name, last_name, email, phone_number, id))
    mysql.connection.commit()
    cur.close()
    return jsonify({'message': 'Customer updated successfully'})

@app.route('/customers/<int:id>', methods=['DELETE'])
def delete_customer(id):
    cur = mysql.connection.cursor()
    cur.execute("DELETE FROM Customers WHERE Customer_ID = %s", (id,))
    mysql.connection.commit()
    cur.close()
    return jsonify({'message': 'Customer deleted successfully'})

@app.route('/customers/<int:id>', methods=['GET'])
def get_customer(id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM Customers WHERE Customer_ID = %s", (id,))
    result = cur.fetchone()
    cur.close()
    if result:
        return jsonify(result)
    else:
        return jsonify({'message': 'Customer not found'})

if __name__ == '__main__':
    app.run(debug=True)

