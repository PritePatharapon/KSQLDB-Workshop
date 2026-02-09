--- Step 1: Create Source Stream
CREATE STREAM CDC_MF_TXN_RAW_ST_<USER> (
    raw_message VARCHAR  -- Defines the structure of incoming raw messages
) WITH (
    KAFKA_TOPIC = 'CDC_MF_TXN_<USER>',   -- Source Kafka topic
    VALUE_FORMAT = 'KAFKA',              -- Raw Kafka message format
    PARTITIONS = 3,                      -- Number of partitions for scalability
    REPLICAS = 3                         -- Replication factor for fault tolerance
);

--- Step 2: Transform Data
CREATE STREAM CDC_MF_TXN_STG_ST_<USER>
WITH (
    KAFKA_TOPIC = 'CDC_MF_TXN_STG_ST_<USER>',   -- Source Kafka topic
    VALUE_FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                      -- Number of partitions for scalability
    REPLICAS = 3                         -- Replication factor for fault tolerance
) AS

SELECT
    -- Split raw message
    SPLIT(raw_message, '|') AS raw_fields,

    -- Transaction info
    SPLIT(raw_message, '|')[1] AS TXN_ID,
    SPLIT(raw_message, '|')[2] AS TXN_TYPE,
    SPLIT(raw_message, '|')[3] AS TXN_CODE,

    -- Amount
    CAST(SPLIT(raw_message, '|')[4] AS DOUBLE) AS TXN_AMT,

    -- Account & metadata
    SPLIT(raw_message, '|')[5] AS ACC_NO,
    SPLIT(raw_message, '|')[6] AS TXN_DT,
    SPLIT(raw_message, '|')[7] AS CHANNEL,
    SPLIT(raw_message, '|')[8] AS UPDATE_TS

FROM CDC_MF_TXN_RAW_ST_<USER>
WHERE SPLIT(raw_message, '|')[1] NOT IN ('000000','999999') OR SPLIT(raw_message, '|')[7] != 'Mobile';

--- Step 3 Filtering Reject Condition
CREATE STREAM CDC_MF_TXN_STG_REJ_ST_<USER>
WITH (
    KAFKA_TOPIC = 'CDC_MF_TXN_STG_REJ_ST_<USER>',  -- Source Kafka topic
    VALUE_FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                      -- Number of partitions for scalability
    REPLICAS = 3                         -- Replication factor for fault tolerance
) AS

SELECT
    -- Split raw message
    SPLIT(raw_message, '|') AS raw_fields,

    -- Transaction info
    SPLIT(raw_message, '|')[1] AS TXN_ID,
    SPLIT(raw_message, '|')[2] AS TXN_TYPE,
    SPLIT(raw_message, '|')[3] AS TXN_CODE,

    -- Amount
    CAST(SPLIT(raw_message, '|')[4] AS DOUBLE) AS TXN_AMT,

    -- Account & metadata
    SPLIT(raw_message, '|')[5] AS ACC_NO,
    MASK_KEEP_LEFT(SPLIT(raw_message, '|')[5], 4, 'X', 'x', 'n', '-') AS ACC_NO_MASK,
    SPLIT(raw_message, '|')[6] AS TXN_DT,
    SPLIT(raw_message, '|')[7] AS CHANNEL,
    SPLIT(raw_message, '|')[8] AS UPDATE_TS

FROM CDC_MF_TXN_RAW_ST_<USER>
WHERE SPLIT(raw_message, '|')[7] = 'Mobile';
