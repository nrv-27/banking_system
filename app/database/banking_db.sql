-- =====================================================
-- Banking System Database
-- Author: Neerav Sharma
-- Description: Simple banking system with customers,
-- accounts, transactions, procedures, triggers & views
-- =====================================================

-- ---------- Database ----------
DROP DATABASE IF EXISTS banking_system;
CREATE DATABASE banking_system;
USE banking_system;

-- ---------- Customers Table ----------
CREATE TABLE customers (
    cust_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    phone VARCHAR(15) UNIQUE NOT NULL
);

-- ---------- Accounts Table ----------
CREATE TABLE accounts (
    acc_no INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT NOT NULL,
    acc_type ENUM('SAVINGS', 'CURRENT') DEFAULT 'SAVINGS',
    balance DECIMAL(10,2) DEFAULT 0.00,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id) ON DELETE CASCADE
);

-- ---------- Transactions Table ----------
CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    acc_no INT NOT NULL,
    txn_type ENUM('DEPOSIT','WITHDRAW') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    txn_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (acc_no) REFERENCES accounts(acc_no) ON DELETE CASCADE
);

-- ---------- Trigger: Prevent Negative Balance ----------
DELIMITER //
CREATE TRIGGER prevent_negative_balance
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Account balance cannot be negative';
    END IF;
END //
DELIMITER ;

-- ---------- Procedure: Perform Transaction ----------
DELIMITER //
CREATE PROCEDURE PerformTransaction(
    IN p_acc_no INT,
    IN p_type ENUM('DEPOSIT','WITHDRAW'),
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE current_balance DECIMAL(10,2);

    SELECT balance INTO current_balance
    FROM accounts
    WHERE acc_no = p_acc_no;

    IF p_type = 'DEPOSIT' THEN
        UPDATE accounts
        SET balance = balance + p_amount
        WHERE acc_no = p_acc_no;

    ELSEIF p_type = 'WITHDRAW' THEN
        IF current_balance >= p_amount THEN
            UPDATE accounts
            SET balance = balance - p_amount
            WHERE acc_no = p_acc_no;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient balance';
        END IF;
    END IF;

    INSERT INTO transactions (acc_no, txn_type, amount)
    VALUES (p_acc_no, p_type, p_amount);
END //
DELIMITER ;

-- ---------- Procedure: Add New Customer + Account ----------
DELIMITER //
CREATE PROCEDURE AddNewCustomerAccount(
    IN p_name VARCHAR(50),
    IN p_address VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_acc_type ENUM('SAVINGS', 'CURRENT'),
    IN p_initial_balance DECIMAL(10,2)
)
BEGIN
    DECLARE new_cust_id INT;

    INSERT INTO customers (name, address, phone)
    VALUES (p_name, p_address, p_phone);

    SET new_cust_id = LAST_INSERT_ID();

    INSERT INTO accounts (cust_id, acc_type, balance)
    VALUES (new_cust_id, p_acc_type, p_initial_balance);
END //
DELIMITER ;

-- ---------- Procedure: Add Account for Existing Customer ----------
DELIMITER //
CREATE PROCEDURE AddAccountForExistingCustomer(
    IN p_cust_id INT,
    IN p_acc_type ENUM('SAVINGS', 'CURRENT'),
    IN p_initial_balance DECIMAL(10,2)
)
BEGIN
    INSERT INTO accounts (cust_id, acc_type, balance)
    VALUES (p_cust_id, p_acc_type, p_initial_balance);
END //
DELIMITER ;

-- ---------- View: Customer Summary ----------
CREATE VIEW customer_summary AS
SELECT 
    c.cust_id,
    c.name,
    c.phone,
    a.acc_no,
    a.acc_type,
    a.balance
FROM customers c
JOIN accounts a ON c.cust_id = a.cust_id;

-- ---------- Sample Data ----------
CALL AddNewCustomerAccount('Rohit Sharma', 'Mumbai', '9876543210', 'SAVINGS', 15000);
CALL AddNewCustomerAccount('Priya Verma', 'Delhi', '9123456780', 'CURRENT', 25000);
CALL AddNewCustomerAccount('Amit Patel', 'Ahmedabad', '9988776655', 'SAVINGS', 10000);

-- ---------- Sample Transactions ----------
CALL PerformTransaction(1, 'DEPOSIT', 5000);
CALL PerformTransaction(1, 'WITHDRAW', 2000);

-- ---------- Verification ----------
SELECT * FROM customer_summary;
SELECT * FROM transactions ORDER BY txn_date DESC;
SELECT SUM(balance) AS total_bank_balance FROM accounts;
