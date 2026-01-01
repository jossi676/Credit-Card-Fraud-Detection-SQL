CREATE DATABASE credit_card_fraud;
USE credit_card_fraud;

CREATE TABLE customers (
    customer_id VARCHAR(40) PRIMARY KEY,
    customer_name VARCHAR(100),
    age INT,
    city VARCHAR(50),
    risk_category VARCHAR(20),
    signup_date DATE
);

CREATE TABLE customers (
    customer_id VARCHAR(40) PRIMARY KEY,
    customer_name VARCHAR(100),
    age INT,
    city VARCHAR(50),
    risk_category VARCHAR(20),
    signup_date DATE
);


CREATE TABLE accounts (
    account_id VARCHAR(40) PRIMARY KEY,
    customer_id VARCHAR(40),
    account_type VARCHAR(20),
    balance DECIMAL(12,2)
);

CREATE TABLE merchants (
    merchant_id VARCHAR(40) PRIMARY KEY,
    merchant_name VARCHAR(100),
    merchant_category VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE devices (
    device_id VARCHAR(40) PRIMARY KEY,
    device_type VARCHAR(20),
    os VARCHAR(20)
);

CREATE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(40),
    merchant_id VARCHAR(40),
    device_id VARCHAR(40),
    transaction_amount DECIMAL(12,2),
    transaction_time DATETIME,
    transaction_city VARCHAR(50),
    transaction_status VARCHAR(20)
);
USE credit_card_fraud;

USE credit_card_fraud;

SELECT
    transaction_id,
    account_id,
    transaction_amount
FROM transactions
ORDER BY transaction_amount DESC
LIMIT 10;


USE credit_card_fraud;

SELECT
    account_id,
    transaction_id,
    transaction_time,
    prev_transaction_time,
    time_diff_minutes
FROM (
    SELECT
        account_id,
        transaction_id,
        transaction_time,
        LAG(transaction_time) OVER (
            PARTITION BY account_id
            ORDER BY transaction_time
        ) AS prev_transaction_time,
        TIMESTAMPDIFF(
            MINUTE,
            LAG(transaction_time) OVER (
                PARTITION BY account_id
                ORDER BY transaction_time
            ),
            transaction_time
        ) AS time_diff_minutes
    FROM transactions
) t
WHERE time_diff_minutes IS NOT NULL
  AND time_diff_minutes <= 5
ORDER BY account_id, transaction_time;

USE credit_card_fraud;

SELECT
    account_id,
    COUNT(DISTINCT transaction_city) AS distinct_cities
FROM transactions
GROUP BY account_id
HAVING COUNT(DISTINCT transaction_city) > 2
ORDER BY distinct_cities DESC;


USE credit_card_fraud;

SELECT
    t.account_id,
    COUNT(DISTINCT t.device_id) AS distinct_devices
FROM transactions t
GROUP BY t.account_id
HAVING COUNT(DISTINCT t.device_id) > 3
ORDER BY distinct_devices DESC;


USE credit_card_fraud;

SELECT
    merchant_id,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS failure_ratio
FROM transactions
GROUP BY merchant_id
HAVING failure_ratio > 0.30
ORDER BY failure_ratio DESC;


SELECT
    t.account_id,

    /* High-value transaction flag */
    CASE 
        WHEN MAX(t.transaction_amount) >= 100000 THEN 1 
        ELSE 0 
    END AS high_value_flag,

    /* Location jump flag */
    CASE 
        WHEN COUNT(DISTINCT t.transaction_city) > 2 THEN 1 
        ELSE 0 
    END AS location_flag,

    /* Device switching flag */
    CASE 
        WHEN COUNT(DISTINCT t.device_id) > 3 THEN 1 
        ELSE 0 
    END AS device_flag,

    /* Failed transaction flag */
    CASE 
        WHEN 
            SUM(CASE WHEN t.transaction_status = 'FAILED' THEN 1 ELSE 0 END) 
            / COUNT(*) > 0.3 
        THEN 1 
        ELSE 0 
    END AS failure_flag

FROM transactions t
GROUP BY t.account_id;

SELECT
    account_id,
    high_value_flag,
    location_flag,
    device_flag,
    failure_flag,
    (high_value_flag + location_flag + device_flag + failure_flag) AS risk_score
FROM (
    SELECT
        t.account_id,
        CASE WHEN MAX(t.transaction_amount) >= 100000 THEN 1 ELSE 0 END AS high_value_flag,
        CASE WHEN COUNT(DISTINCT t.transaction_city) > 2 THEN 1 ELSE 0 END AS location_flag,
        CASE WHEN COUNT(DISTINCT t.device_id) > 3 THEN 1 ELSE 0 END AS device_flag,
        CASE 
            WHEN SUM(CASE WHEN t.transaction_status = 'FAILED' THEN 1 ELSE 0 END) 
                 / COUNT(*) > 0.3 
            THEN 1 ELSE 0 
        END AS failure_flag
    FROM transactions t
    GROUP BY t.account_id
) risk_summary
WHERE (high_value_flag + location_flag + device_flag + failure_flag) > 0
ORDER BY risk_score DESC;
 
 USE credit_card_fraud;

SELECT
    account_id,
    high_value_flag,
    location_flag,
    device_flag,
    failure_flag,
    (high_value_flag + location_flag + device_flag + failure_flag) AS risk_score
FROM (
    SELECT
        account_id,

        /* High-value transaction */
        CASE 
            WHEN MAX(transaction_amount) >= 2.5 * AVG(transaction_amount)
            THEN 1 ELSE 0
        END AS high_value_flag,

        /* Location anomaly */
        CASE 
            WHEN COUNT(DISTINCT transaction_city) > 2
            THEN 1 ELSE 0
        END AS location_flag,

        /* Device switching */
        CASE 
            WHEN COUNT(DISTINCT device_id) > 3
            THEN 1 ELSE 0
        END AS device_flag,

        /* High failure rate */
        CASE 
            WHEN SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) / COUNT(*) > 0.3
            THEN 1 ELSE 0
        END AS failure_flag

    FROM transactions
    GROUP BY account_id
) t
WHERE (high_value_flag + location_flag + device_flag + failure_flag) >= 2
ORDER BY risk_score DESC;

