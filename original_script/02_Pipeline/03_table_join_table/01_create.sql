---Step 1 Create source Table
CREATE TABLE "CDC-MF-TXN-STG-PREP-JOIN-TB-<USER>" WITH (
    KAFKA_TOPIC = 'CDC-MF-TXN-STG-PREP-JOIN-TB-<USER>',   -- Source Kafka topic
    VALUE_FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                      -- Number of partitions for scalability
    REPLICAS = 1                         -- Replication factor for fault tolerance
) AS
SELECT
    ACC_NO AS ACC_NO,
    LATEST_BY_OFFSET(TXN_ID) AS LATEST_TXN_ID,
    LATEST_BY_OFFSET(TXN_TYPE) AS LATEST_TXN_TYPE,
    LATEST_BY_OFFSET(TXN_AMT) AS LATEST_TXN_AMT,
    LATEST_BY_OFFSET(TXN_DT) AS LATEST_TXN_DT
FROM "CDC-MF-TXN-STG-ST-<USER>"
GROUP BY ACC_NO;

---Step 2 Enrichment Account Table with Transaction Table
CREATE TABLE "CDC-DB-MASTER-ACC-STG-JOIN-TABLE-TABLE-ST-<USER>" WITH (
  KAFKA_TOPIC = 'CDC-DB-MASTER-ACC-STG-JOIN-TABLE-TABLE-ST-<USER>',      -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 1                   -- Replication factor for fault tolerance
) AS
SELECT
    A.ACCOUNT_ID,
    A.ACCOUNT_NAME,
    A.ACCOUNT_TYPE,
    T.LATEST_TXN_ID,
    T.LATEST_TXN_AMT,
    T.LATEST_TXN_DT
FROM "CDC-MF-TXN-STG-PREP-JOIN-TB-<USER>" T
LEFT JOIN "CDC-DB-MASTER-ACC-RAW-TB-<USER>" A 
ON T.ACC_NO = A.ACCOUNT_ID;
