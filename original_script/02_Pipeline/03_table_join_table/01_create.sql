---Step 1 Create source Table
CREATE TABLE CDC_MF_TXN_STG_PREP_JOIN_TB_<USER> WITH (
    KAFKA_TOPIC = 'CDC_MF_TXN_STG_PREP_JOIN_<USER>',   -- Source Kafka topic
    VALUE_FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                      -- Number of partitions for scalability
    REPLICAS = 3                         -- Replication factor for fault tolerance
) AS
SELECT
    ACC_NO AS ACC_NO,
    LATEST_BY_OFFSET(TXN_ID) AS TXN_ID,
    LATEST_BY_OFFSET(TXN_TYPE) AS TXN_TYPE,
    LATEST_BY_OFFSET(TXN_AMT) AS TXN_AMT,
    LATEST_BY_OFFSET(TXN_DT) AS TXN_DT
FROM CDC_MF_TXN_STG_ST_<USER>
GROUP BY ACC_NO;

---Step 2 Enrichment Account Table with Transaction Table
CREATE TABLE CDC_DB_MASTER_ACC_STG_JOIN_TABLE_TABLE_ST_<USER> WITH (
  KAFKA_TOPIC = 'CDC_DB_MASTER_ACC_STG_JOIN_TABLE_TABLE_<USER>',      -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 3                   -- Replication factor for fault tolerance
) AS
SELECT
    A.ACCOUNT_ID,
    A.ACCOUNT_NAME,
    A.ACCOUNT_TYPE,
    T.LATEST_TXN_ID,
    T.LATEST_TXN_AMT,
    T.LAST_TXN_TIME
FROM CDC_MF_TXN_STG_PREP_JOIN_TB_<USER> T
LEFT JOIN CDC_DB_MASTER_ACC_RAW_TB_<USER> A 
ON T.ACC_NO = A.ACCOUNT_ID;