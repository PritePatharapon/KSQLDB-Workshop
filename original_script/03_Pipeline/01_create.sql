---Step 1 Create source Stream
CREATE STREAM MB_LOGIN_EVENTS_RAW_ST_<USER> (
    USER_ID VARCHAR KEY,
    DEVICE_TYPE VARCHAR, -- iOS, Android, Web
    LOGIN_STATUS VARCHAR -- SUCCESS, FAIL
) WITH (
  KAFKA_TOPIC = 'MB_LOGIN_EVENTS_RAW_ST_<USER>',      -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 1                   -- Replication factor for fault tolerance
);

---Step 2 Create Aggregation data with Tumbling window
CREATE TABLE MB_LOGIN_EVENTS_STG_TUMBLING_ST_<USER> WITH (
    KAFKA_TOPIC = 'MB_LOGIN_EVENTS_STG_TUMBLING_<USER>',      -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 1                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM MB_LOGIN_EVENTS_RAW_ST_<USER>
WINDOW TUMBLING (SIZE 30 SECONDS)
GROUP BY USER_ID;

---Step 4 Create Aggregation data with Hopping window
CREATE TABLE MB_LOGIN_EVENTS_STG_HOPPING_TB_<USER> WITH (
    KAFKA_TOPIC = 'MB_LOGIN_EVENTS_STG_HOPPING_<USER>',      -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 1                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM MB_LOGIN_EVENTS_RAW_ST_<USER>
WINDOW HOPPING (SIZE 30 SECONDS, ADVANCE BY 10 SECONDS)
GROUP BY USER_ID;

---Step 6 Create Aggregation data with Session window
CREATE TABLE MB_LOGIN_EVENTS_STG_SESSION_TB_<USER> WITH (
    KAFKA_TOPIC = 'MB_LOGIN_EVENTS_STG_SESSION_<USER>',    -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 1                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM MB_LOGIN_EVENTS_RAW_ST_<USER>
WINDOW SESSION (30 SECONDS)
GROUP BY USER_ID;