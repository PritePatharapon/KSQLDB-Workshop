---Step 1 Create source Stream
CREATE STREAM "MB-LOGIN-EVENTS-RAW-ST-<USER>" (
    USER_ID VARCHAR KEY,
    DEVICE_TYPE VARCHAR, -- iOS, Android, Web
    LOGIN_STATUS VARCHAR -- SUCCESS, FAIL
) WITH (
  KAFKA_TOPIC = 'MB-LOGIN-EVENTS-RAW-ST-<USER>',      -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 1                   -- Replication factor for fault tolerance
);

---Step 2 Create Aggregation data with Tumbling window
CREATE TABLE "MB-LOGIN-EVENTS-STG-TUMBLING-ST-<USER>" WITH (
    KAFKA_TOPIC = 'MB-LOGIN-EVENTS-STG-TUMBLING-ST-<USER>',      -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 1                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM "MB-LOGIN-EVENTS-RAW-ST-<USER>"
WINDOW TUMBLING (SIZE 30 SECONDS)
GROUP BY USER_ID;

---Step 4 Create Aggregation data with Hopping window
CREATE TABLE "MB-LOGIN-EVENTS-STG-HOPPING-TB-<USER>" WITH (
    KAFKA_TOPIC = 'MB-LOGIN-EVENTS-STG-HOPPING-TB-<USER>',      -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 1                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM "MB-LOGIN-EVENTS-RAW-ST-<USER>"
WINDOW HOPPING (SIZE 30 SECONDS, ADVANCE BY 10 SECONDS)
GROUP BY USER_ID;

---Step 6 Create Aggregation data with Session window
CREATE TABLE "MB-LOGIN-EVENTS-STG-SESSION-TB-<USER>" WITH (
    KAFKA_TOPIC = 'MB-LOGIN-EVENTS-STG-SESSION-TB-<USER>',    -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 1                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM "MB-LOGIN-EVENTS-RAW-ST-<USER>"
WINDOW SESSION (30 SECONDS)
GROUP BY USER_ID;
