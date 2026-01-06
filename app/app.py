from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
import webbrowser
import threading

app = Flask(__name__)
app.secret_key = 'supersecretkey'

# ✅ Database connection function
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Sqlpassword",  # 🔹 Replace with your actual MySQL password
        database="banking_system"
    )

# 🏠 Home route
@app.route('/')
def index():
    return render_template('index.html')

# 👥 View & Add Customers
@app.route('/customers', methods=['GET', 'POST'])
def customers():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        name = request.form['name']
        address = request.form['address']
        phone = request.form['phone']
        acc_type = request.form['acc_type']
        balance = float(request.form['balance'])
        try:
            cursor.callproc('AddNewCustomerAccount', (name, address, phone, acc_type, balance))
            conn.commit()
            flash('✅ Customer and account added successfully!', 'success')
        except mysql.connector.Error as err:
            flash(f'❌ Error: {err}', 'danger')

    cursor.execute("SELECT * FROM customer_summary")
    customers = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('customers.html', customers=customers)

# 💰 View All Accounts
@app.route('/accounts')
def accounts():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM accounts")
    accounts = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('accounts.html', accounts=accounts)

# 💸 Perform a new transaction (Deposit / Withdraw)
@app.route('/make_transaction', methods=['GET', 'POST'])
def make_transaction():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # ✅ Correct SQL query
    cursor.execute("""
        SELECT a.acc_no, c.name 
        FROM accounts a
        JOIN customers c ON a.cust_id = c.cust_id
    """)
    accounts = cursor.fetchall()

    if request.method == 'POST':
        acc_no = request.form['acc_no']
        txn_type = request.form['txn_type']
        amount = float(request.form['amount'])

        try:
            cursor.callproc('PerformTransaction', [acc_no, txn_type, amount])
            conn.commit()
            flash('Transaction successful!', 'success')
        except mysql.connector.Error as err:
            flash(f'Error: {err.msg}', 'danger')

    cursor.close()
    conn.close()
    return render_template('make_transaction.html', accounts=accounts)

# 📜 Show All Transaction Records
@app.route('/transactions')
def transactions():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM transactions ORDER BY txn_date DESC")
    transactions = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('transactions.html', transactions=transactions)

# 🌐 Automatically open the app in the browser
def open_browser():
    webbrowser.open_new("http://127.0.0.1:5000/")

if __name__ == '__main__':
    threading.Timer(1.5, open_browser).start()
    app.run(debug=True)

