
# Credit Card Fraud Detection using SQL (MySQL)

## Project Overview
This project simulates a real-world credit card fraud monitoring system using MySQL. 
The objective is to identify suspicious transactions and accounts by applying multiple 
fraud detection rules commonly used by banks and fintech companies.

The analysis is based on structured transaction data and focuses on behavioral, 
velocity, geographic, device, and merchant-level risk signals.

---

## Dataset Description
The project uses five relational tables:

*transactions – Individual card transactions with amount, time, city, device, and status
*accounts – Card/account-level information
*customers – Customer demographic details
*devices – Device metadata used for transactions
*merchants – Merchant identifiers and transaction history

---

## Fraud Detection Scenarios Implemented

1. High-Value Behavioral Anomaly
Identifies transactions that are significantly higher than a customer’s normal spending behavior.
- Rule: Transaction amount ≥ 2.5× account’s average transaction amount

2. Rapid Transaction Velocity
Detects multiple transactions occurring within a very short time window.
- Rule: Transactions within 5 minutes for the same account  


3. Location Jump (Geo-Velocity)
Flags accounts transacting across multiple cities.
- Rule: More than 2 distinct transaction cities per account

4. Device Switching
Detects potential account takeover by monitoring device usage.
- Rule: More than 3 distinct devices per account

5. High-Risk Merchants
Identifies merchants with abnormal transaction failure rates.
- Rule: Failure rate > 30%

---

## Key Outcome
Instead of relying on a single rule, this project demonstrates how multiple independent 
risk signals can be layered together to assess fraud risk realistically.
