CREATE DATABASE banking_system;
USE banking_system;

CREATE TABLE customers (
    cust_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    address VARCHAR(100),
    phone VARCHAR(15)
);

CREATE TABLE accounts (
    acc_no INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT,
    acc_type VARCHAR(20),
    balance DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
);

CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    acc_no INT,
    txn_type ENUM('DEPOSIT','WITHDRAW'),
    amount DECIMAL(10,2),
    txn_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (acc_no) REFERENCES accounts(acc_no)
);

INSERT INTO customers (name, address, phone) VALUES
('Rohit Sharma', 'Mumbai', '9876543210'),
('Priya Verma', 'Delhi', '9123456780'),
('Amit Patel', 'Ahmedabad', '9988776655');

INSERT INTO accounts (cust_id, acc_type, balance) VALUES
(1, 'SAVINGS', 15000),
(2, 'CURRENT', 25000),
(3, 'SAVINGS', 10000);

DELIMITER //
CREATE PROCEDURE PerformTransaction(
    IN p_acc_no INT,
    IN p_type ENUM('DEPOSIT','WITHDRAW'),
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE current_balance DECIMAL(10,2);
    SELECT balance INTO current_balance FROM accounts WHERE acc_no = p_acc_no;
    IF p_type = 'DEPOSIT' THEN
        UPDATE accounts SET balance = balance + p_amount WHERE acc_no = p_acc_no;
    ELSEIF p_type = 'WITHDRAW' THEN
        IF current_balance >= p_amount THEN
            UPDATE accounts SET balance = balance - p_amount WHERE acc_no = p_acc_no;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance!';
        END IF;
    END IF;
    INSERT INTO transactions (acc_no, txn_type, amount)
    VALUES (p_acc_no, p_type, p_amount);
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER prevent_negative_balance
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Account balance cannot be negative!';
    END IF;
END //
DELIMITER ;

CREATE VIEW customer_summary AS
SELECT c.name, a.acc_no, a.acc_type, a.balance
FROM customers c
JOIN accounts a ON c.cust_id = a.cust_id;

CALL PerformTransaction(1, 'DEPOSIT', 5000);
CALL PerformTransaction(1, 'WITHDRAW', 2000);

SELECT * FROM customer_summary;
SELECT * FROM transactions ORDER BY txn_date DESC;
SELECT SUM(balance) AS total_bank_balance FROM accounts;
SELECT c.name, a.acc_no, a.acc_type, a.balance
FROM customers c
JOIN accounts a ON c.cust_id = a.cust_id
WHERE a.acc_no = 1;

select * from customers;

select * from accounts;

call PerformTransaction(2,'WITHDRAW',5000);
select * from accounts;
