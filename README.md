# ksqlDB Workshop — Getting Started with Streaming SQL
## Agendar
## Overview
ksqlDB is a database for building stream processing applications on top of Apache Kafka. It is **distributed**, **scalable**, **reliable**, and **real-time**. ksqlDB combines the power of real-time stream processing with the approachable feel of a relational database through a familiar, lightweight SQL syntax.
<p align="center">
  <img src="Image/ksqldb-kafka-db.png" width="600"/>
</p>

---

## How ksqlDB work with Kafka
ksqlDB separates its distributed compute layer from its distributed storage layer, for which it uses Apache Kafka.
<p align="center">
  <img src="Image/ksqldb-kafka.png" width="400"/>
  <img src="Image/ksql.svg" width="400"/>
</p>


ksqlDB allows us to read, filter, transform, or otherwise process streams and tables of events, which are backed by Kafka topics. We can also join streams and/or tables to meet the needs of our application. And we can do all of this using familiar SQL syntax.

---

## Basic standing concept on ksqlDB
### Stream and Table
**Stream** is a partitioned, immutable, append-only collection that represents a series of historical facts. Once a row is inserted into a stream, it can never change. New rows can be appended at the end of the stream, **but existing rows can never be updated or deleted**.

**Table** is a mutable, partitioned collection that models change over time. In contrast with a stream, which represents a historical sequence of events, a table represents what is true as of **“now”**. 

<p align="center">
  <img src="Image/Stream-GIF.gif" width="500"/>
</p>

&nbsp;


### Materialized views (Stateful)
You can use ksqlDB to build a materialized view of state on a specific server by using RocksDB, driven by the events in an Apache Kafka topic. This is done using SQL aggregation functions, such as `COUNT` and `SUM`.
<p align="center">
  <img src="Image/StateStore.png" width="300"/>
</p>

---

## ksqlDB Data pipeline
### Overview Data pipeline

Pipeline 1: Transformation, filtering

Pipeline 2: Enrichment

Pipeline 3: Aggregation and window time



### Pipeline 1: Transformation, filtering, Aggregate
#### Step 1 Create source stream
```sql
CREATE STREAM CDC_MF_TXN_RAW_ST_<USER> (
    raw_message VARCHAR  -- Defines the structure of incoming raw messages
) WITH (
    KAFKA_TOPIC = 'CDC_MF_TXN_<USER>',   -- Source Kafka topic
    VALUE_FORMAT = 'KAFKA',              -- Raw Kafka message format
    PARTITIONS = 3,                      -- Number of partitions for scalability
    REPLICAS = 3                         -- Replication factor for fault tolerance
);
```

#### Output:

---

#### Step 2 Transform Data
```sql
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
WHERE TXN_ID NOT IN ('000000','999999') OR CHANNEL != 'Mobile';
```

#### Output:
---

#### Step 3 Filtering Reject Condition
```sql
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
    SPLIT(raw_message, '|')[6] AS TXN_DT,
    SPLIT(raw_message, '|')[7] AS CHANNEL,
    SPLIT(raw_message, '|')[8] AS UPDATE_TS

FROM CDC_MF_TXN_RAW_ST_<USER>
WHERE CHANNEL = 'Mobile';
```

#### Output:
---

#### Step 4 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_MF_TXN_STG_ST_<USER>
```
#### Output:

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Reject Data
Select * From CDC_MF_TXN_STG_REJ_ST_<USER>
```

#### Output:
---

### Pipeline 2.1: Enrichment Stream with Stream 
#### Step 1 Create source Stream
```SQL
CREATE STREAM CDC_DB_MASTER_ACC_RAW_ST_<USER> (
  ACCOUNT_ID VARCHAR KEY,
  ACCOUNT_NAME VARCHAR,
  ACCOUNT_BALANCE DOUBLE,
  ACCOUNT_TYPE VARCHAR,
  UPDATE_TS TIMESTAMP,
  __OP STRING
) WITH (
  KAFKA_TOPIC = 'CDC_DB_MASTER_ACC_<USER>',  -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 3                   -- Replication factor for fault tolerance
);
```

#### Output:
---

#### Step 2 Enrich Stream and Stream
```SQL
SET 'auto.offset.reset' = 'latest';  -- Ignore existing messages and read new data only

CREATE STREAM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER> WITH (
    KAFKA_TOPIC = 'CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_<USER>', -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 3                   -- Replication factor for fault tolerance
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
FROM CDC_DB_MASTER_ACC_RAW_ST_<USER> A
INNER JOIN CDC_MF_TXN_STG_ST_<USER> T 
WITHIN 30 SECONDS  -- Define join window between two streams
ON A.ACCOUNT_ID = T.ACC_NO;
```

#### Output:
---

#### Step 3 Insert and Select Data within window time

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER>
```
#### Output:

---


#### Step 4 Insert and Select Data without window time

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER>
```
#### Output:

---

### Pipeline 2.2: Enrichment Stream with Table 
#### Step 1 Create source Table
```SQL
CREATE STREAM CDC_DB_MASTER_ACC_RAW_TB_<USER> (
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
  REPLICAS = 3                   -- Replication factor for fault tolerance
);
```
#### Output:
---

#### Step 2 Enrichment Stream with Table
```SQL
CREATE STREAM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_TABLE_ST_<USER> WITH (
  KAFKA_TOPIC = 'CDC_DB_MASTER_ACC_STG_JOIN_STREAM_TABLE_ST_<USER>',      -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 3                   -- Replication factor for fault tolerance
) AS 
SELECT 
    A.STRUCT_KEY AS JOIN_KEY,
    T.TXN_ID AS TXN_ID,
    T.TXN_CODE AS TXN_CODE,
    T.TXN_AMT AS TXN_AMT,
    T.ACCOUNT_ID AS ACCOUNT_ID,
    A.ACCOUNT_NAME AS ACCOUNT_NAME,
    A.ACCOUNT_TYPE AS ACCOUNT_TYPE,
    A.ACCOUNT_BALANCE AS ACCOUNT_BALANCE
FROM CDC_MF_TXN_STG_ST_<USER> T
LEFT JOIN CDC_DB_MASTER_ACC_RAW_ST_<USER> A    
ON T.ACC_NO = A.ACCOUNT_ID;
```
#### Step 3 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER>
```
#### Output:
---
#### Step 4 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER>
```
#### Output:

---

### Pipeline 2.3: Enrichment Table with Table 
#### Step 1 Create source Table

``` SQL
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
```


#### Step 2 Enrichment Account Table with Transaction Table
```SQL
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
```
#### Step 3 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_TABLE_TABLE_ST_<USER>
```
#### Output:
---
#### Step 4 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_TABLE_TABLE_ST_<USER>
```
#### Output:
---

### Pipeline 3: Aggregation and Window time
#### Step 1 Create source stream
```SQL
CREATE STREAM MB_LOGIN_EVENTS_RAW_ST_<USER> (
    USER_ID VARCHAR KEY,
    DEVICE_TYPE VARCHAR, -- iOS, Android, Web
    LOGIN_STATUS VARCHAR -- SUCCESS, FAIL
) WITH (
  KAFKA_TOPIC = 'MB_LOGIN_EVENTS_RAW_ST_<USER>',      -- Source Kafka topic
  FORMAT = 'JSON',               -- JSON message format
  PARTITIONS = 3,                -- Number of partitions for scalability
  REPLICAS = 3                   -- Replication factor for fault tolerance
);
```

#### Step 2 Create Aggregation data with Tumbling window
```SQL
CREATE TABLE MB_LOGIN_EVENTS_STG_TUMBLING_ST_<USER> WITH (
    KAFKA_TOPIC = 'BAAC_AGG_LOGIN_TUMBLING_<USER>',      -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 3                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM MB_LOGIN_EVENTS_RAW_ST_<USER>
WINDOW TUMBLING (SIZE 30 SECONDS)
GROUP BY USER_ID;
```
#### Step 3 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM BAAC_AGG_LOGIN_TUMBLING_TB_<USER>
```

#### Step 4 Create Aggregation data with Hopping window
```SQL
CREATE TABLE MB_LOGIN_EVENTS_STG_HOPPING_TB_<USER> WITH (
    KAFKA_TOPIC = 'MB_LOGIN_EVENTS_STG_HOPPING_<USER>',      -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 3                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM MB_LOGIN_EVENTS_RAW_ST_<USER>
WINDOW HOPPING (SIZE 30 SECONDS, ADVANCE BY 10 SECONDS)
GROUP BY USER_ID;
```

#### Step 5 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM MB_LOGIN_EVENTS_STG_HOPPING_TB_<USER>
```

#### Step 6 Create Aggregation data with Session window
```SQL
CREATE TABLE MB_LOGIN_EVENTS_STG_SESSION_TB_<USER> WITH (
    KAFKA_TOPIC = 'MB_LOGIN_EVENTS_STG_SESSION_<USER>',    -- Source Kafka topic
    FORMAT = 'JSON',               -- JSON message format
    PARTITIONS = 3,                -- Number of partitions for scalability
    REPLICAS = 3                   -- Replication factor for fault tolerance
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM BAAC_RAW_LOGIN_EVENTS_ST
WINDOW SESSION (30 SECONDS)
GROUP BY USER_ID;
```

#### Step 7 Insert and Select Data

```sql
-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO
```

```sql
SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM MB_LOGIN_EVENTS_STG_SESSION_TB_<USER>
```




## Operation
### Logging
### Error handling
### Monitoring
#### Grafana
#### Confluent Control Center
