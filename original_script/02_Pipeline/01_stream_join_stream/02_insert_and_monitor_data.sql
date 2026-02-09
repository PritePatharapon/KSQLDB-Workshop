-- Monitor Output Stream (Joined Data)
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER> EMIT CHANGES;

-- Step 1: Insert Account Data (Stream Source)
-- Note: Logic requires JOIN within 30 seconds.
INSERT INTO CDC_DB_MASTER_ACC_RAW_ST_<USER> (ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_BALANCE, ACCOUNT_TYPE, UPDATE_TS, __OP) 
VALUES ('ACC001', 'John Doe', 10000.00, 'Savings', '2024-02-09T10:00:00.000', 'c');

INSERT INTO CDC_DB_MASTER_ACC_RAW_ST_<USER> (ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_BALANCE, ACCOUNT_TYPE, UPDATE_TS, __OP) 
VALUES ('ACC002', 'Jane Smith', 50000.00, 'Current', '2024-02-09T10:00:00.000', 'c');

-- Step 2: Insert Transaction Data (Must match Account ID and be within window)
-- Matching ACC001 (Should Join)
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) 
VALUES ('TXN2001|WITHDRAW|W01|1000.00|ACC001|2024-02-09 10:00:10|ATM|2024-02-09 10:00:15');

-- No Match Account (Should NOT appear in Inner Join)
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) 
VALUES ('TXN2002|DEPOSIT|D01|500.00|ACC999|2024-02-09 10:00:10|ATM|2024-02-09 10:00:15');

-- Time Window Miss (If executing manually, wait >30s or simulate timestamps if using Event Time)
-- NOTE: In KSQLDB INSERT, the timestamp is usually processing time unless explicitly set in a customized producer or specific value format hacks. 
-- For this workshop, ensure you run the Transaction INSERT immediately after Account INSERT.