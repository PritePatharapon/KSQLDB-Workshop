--- Step 1 Create source Stream
CREATE STREAM "CDC-DB-MASTER-ACC-RAW-ST-<USER>" (
  ACCOUNT_ID VARCHAR KEY,
  ACCOUNT_NAME VARCHAR,
  ACCOUNT_BALANCE DOUBLE,
  ACCOUNT_TYPE VARCHAR,
  UPDATE_TS TIMESTAMP,
  __OP STRING
) WITH (
  KAFKA_TOPIC = 'CDC-DB-MASTER-ACC-RAW-ST-<USER>',  -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 1                   -- Replication factor for fault tolerance
);

--- Step 2 Create source Stream
SET 'auto.offset.reset' = 'latest';  -- Ignore existing messages and read new data only

CREATE STREAM "CDC-DB-MASTER-ACC-STG-JOIN-STREAM-STREAM-ST-<USER>" WITH (
    KAFKA_TOPIC = 'CDC-DB-MASTER-ACC-STG-JOIN-STREAM-STREAM-ST-<USER>', -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 1                   -- Replication factor for fault tolerance
) AS 
SELECT 
    A.ACCOUNT_ID as ACCOUNT_ID,
    A.ACCOUNT_NAME as ACCOUNT_NAME,
    A.ACCOUNT_BALANCE as ACCOUNT_BALANCE,
    A.ACCOUNT_TYPE as ACCOUNT_TYPE,
    T.TXN_ID as TXN_ID,
    T.TXN_CODE as TXN_CODE,
    T.TXN_AMT as TXN_AMT,
    T.TXN_TYPE as TXN_TYPE,
    T.UPDATE_TS as TRANS_TS,
    A.UPDATE_TS as ACCOUNT_TS
FROM "CDC-DB-MASTER-ACC-RAW-ST-<USER>" A
INNER JOIN "CDC-MF-TXN-STG-ST-<USER>" T 
WITHIN 30 SECONDS  -- Define join window between two streams
ON A.ACCOUNT_ID = T.ACC_NO;
