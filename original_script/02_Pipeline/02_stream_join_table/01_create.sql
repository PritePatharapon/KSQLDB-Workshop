---Step 1 Create source Table
CREATE TABLE "CDC-DB-MASTER-ACC-RAW-TB-<USER>" (
  ACCOUNT_ID VARCHAR PRIMARY KEY,
  ACCOUNT_NAME VARCHAR,
  ACCOUNT_BALANCE DOUBLE,
  ACCOUNT_TYPE VARCHAR,
  UPDATE_TS TIMESTAMP,
  __OP STRING
) WITH (
  KAFKA_TOPIC = 'CDC-DB-MASTER-ACC-RAW-TB-<USER>',  -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 1                   -- Replication factor for fault tolerance
);

---Step 2 Enrichment Stream with Table
CREATE STREAM "CDC-DB-MASTER-ACC-STG-JOIN-STREAM-TABLE-ST-<USER>" WITH (
  KAFKA_TOPIC = 'CDC-DB-MASTER-ACC-STG-JOIN-STREAM-TABLE-ST-<USER>',      -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 1                   -- Replication factor for fault tolerance
) AS 
SELECT 
    A.ACCOUNT_ID AS JOIN_KEY,
    T.TXN_ID AS TXN_ID,
    T.TXN_CODE AS TXN_CODE,
    T.TXN_AMT AS TXN_AMT,
    A.ACCOUNT_NAME AS ACCOUNT_NAME,
    A.ACCOUNT_TYPE AS ACCOUNT_TYPE,
    A.ACCOUNT_BALANCE AS ACCOUNT_BALANCE
FROM "CDC-MF-TXN-STG-ST-<USER>" T
LEFT JOIN "CDC-DB-MASTER-ACC-RAW-TB-<USER>" A    
ON T.ACC_NO = A.ACCOUNT_ID;
