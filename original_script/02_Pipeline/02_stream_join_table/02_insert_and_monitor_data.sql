-- Monitor Source Stream (Transaction Data)
SELECT *, TIMESTAMPTOSTRING(ROWTIME, 'yyyy-MM-dd HH:mm:ss.SSS') AS CURRENT_TIME FROM "CDC-MF-TXN-RAW-ST-<USER>" EMIT CHANGES;

-- Monitor Source Stream (Account Data)
SELECT *, TIMESTAMPTOSTRING(ROWTIME, 'yyyy-MM-dd HH:mm:ss.SSS') AS CURRENT_TIME FROM "CDC-DB-MASTER-ACC-RAW-TB-<USER>" EMIT CHANGES;

-- Monitor Output Stream (Enriched Data)
SET 'auto.offset.reset' = 'latest';
SELECT * FROM "CDC-DB-MASTER-ACC-STG-JOIN-STREAM-TABLE-ST-<USER>" EMIT CHANGES;

-- Step 1: Insert Master Data into TABLE
-- KSQLDB Table mimics state. Updates to the same key overwrite previous values.
INSERT INTO "CDC-DB-MASTER-ACC-RAW-TB-<USER>" (ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_BALANCE, ACCOUNT_TYPE, UPDATE_TS, __OP) 
VALUES ('ACC001', 'John Doe', 12000.00, 'Savings', '2024-02-09T12:00:00.000', 'c');
INSERT INTO "CDC-DB-MASTER-ACC-RAW-TB-<USER>" (ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_BALANCE, ACCOUNT_TYPE, UPDATE_TS, __OP) 
VALUES ('ACC002', 'Jane Smith', 80000.00, 'Current', '2024-02-09T12:00:00.000', 'c');

-- Step 2: Insert Transactions
    -- Case 1: Match Found (Enriched with Name/Balance)
INSERT INTO "CDC-MF-TXN-RAW-ST-<USER>" (raw_message) 
VALUES ('TXN3001|PAYMENT|P01|500.00|ACC001|2024-02-09 12:05:00|App|2024-02-09 12:05:05');
    -- Case 2: No Match Found (Left Join -> Columns will be NULL)
INSERT INTO "CDC-MF-TXN-RAW-ST-<USER>" (raw_message) 
VALUES ('TXN3002|PAYMENT|P01|500.00|ACC003|2024-02-09 12:05:00|App|2024-02-09 12:05:05');

-- Step 3: Update Table Data & Retry
    -- Update ACC001 Balance
INSERT INTO "CDC-DB-MASTER-ACC-RAW-TB-<USER>" (ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_BALANCE, ACCOUNT_TYPE, UPDATE_TS, __OP) 
VALUES ('ACC001', 'John Doe', 11500.00, 'Savings', '2024-02-09T12:10:00.000', 'u');
    -- Insert new transaction for ACC001 (Should see new balance)
INSERT INTO "CDC-MF-TXN-RAW-ST-<USER>" (raw_message) 
VALUES ('TXN3003|PAYMENT|P01|200.00|ACC001|2024-02-09 12:15:00|App|2024-02-09 12:15:05');
