---Step 1 Create source Table
CREATE TABLE CDC_DB_MASTER_ACC_RAW_TB_<USER> (
  ACCOUNT_ID VARCHAR PRIMARY KEY,
  ACCOUNT_NAME VARCHAR,
  ACCOUNT_BALANCE DOUBLE,
  ACCOUNT_TYPE VARCHAR,
  UPDATE_TS TIMESTAMP,
  __OP STRING
) WITH (
  KAFKA_TOPIC = 'CDC_DB_MASTER_ACC_<USER>',  -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 1                   -- Replication factor for fault tolerance
);

---Step 2 Enrichment Stream with Table
CREATE STREAM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_TABLE_ST_<USER> WITH (
  KAFKA_TOPIC = 'CDC_DB_MASTER_ACC_STG_JOIN_STREAM_TABLE_ST_<USER>',      -- Source Kafka topic
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
FROM CDC_MF_TXN_STG_ST_<USER> T
LEFT JOIN CDC_DB_MASTER_ACC_RAW_TB_<USER> A    
ON T.ACC_NO = A.ACCOUNT_ID;