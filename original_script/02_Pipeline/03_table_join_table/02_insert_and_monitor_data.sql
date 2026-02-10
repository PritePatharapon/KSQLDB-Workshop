-- Monitor Output Table (Aggregated & Enriched)
SET 'auto.offset.reset' = 'latest';
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_TABLE_TABLE_ST_<USER> EMIT CHANGES;

-- Pre-requisite: Ensure Table Data exists (Reuse from previous steps or insert again)
INSERT INTO CDC_DB_MASTER_ACC_RAW_TB_<USER> (ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_BALANCE, ACCOUNT_TYPE, UPDATE_TS, __OP) 
VALUES ('ACC001', 'John Doe', 15000.00, 'Savings', '2024-02-09T14:00:00.000', 'c');

-- Insert Transactions to trigger aggregations
-- The pipeline aggregates TXNs by ACC_NO to get LATEST_BY_OFFSET
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) 
VALUES ('TXN4001|TRANSFER|T01|1000.00|ACC001|2024-02-09 14:00:00|ATM|2024-02-09 14:00:05');

-- Monitor: Output should show TXN4001 as latest for ACC001

-- Send another transaction
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) 
VALUES ('TXN4002|TRANSFER|T01|2000.00|ACC001|2024-02-09 14:01:00|ATM|2024-02-09 14:01:05');

-- Monitor: Output should update LATEST_TXN_ID to TXN4002