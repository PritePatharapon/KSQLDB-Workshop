--------------------------------------------- 06 WINDOW AGGREGATION ---------------------------------------------
-- Scenario: ต้องการดูสถิติ Transaction (Frequency & Volume) ในช่วงเวลาต่างๆ
-- Input: สร้าง Raw Stream สำหรับ Test Window โดยเฉพาะ (LOGIN_EVENTS)

-- 1. Create Raw Data for Window Testing (Login Events)
CREATE STREAM BAAC_RAW_LOGIN_EVENTS_ST (
    USER_ID VARCHAR KEY,
    DEVICE_TYPE VARCHAR, -- iOS, Android, Web
    LOGIN_STATUS VARCHAR -- SUCCESS, FAIL
) WITH (
    KAFKA_TOPIC = 'BAAC_RAW_LOGIN_EVENTS',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 1, REPLICAS = 1
);

-- 2.1 TUMBLING WINDOW (Fixed size, No Overlap)
-- Count logins per User every 30 seconds
-- ตัวอย่าง: 10:00:00-10:00:30, 10:00:30-10:01:00
CREATE TABLE BAAC_AGG_LOGIN_TUMBLING_TB WITH (
    KAFKA_TOPIC = 'BAAC_AGG_LOGIN_TUMBLING_TB',
    FORMAT = 'JSON'
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM BAAC_RAW_LOGIN_EVENTS_ST
WINDOW TUMBLING (SIZE 30 SECONDS)
GROUP BY USER_ID
EMIT CHANGES;

-- 2.2 HOPPING WINDOW (Fixed size, Overlap)
-- Count logins per User every 10 seconds, looking back 30 seconds window
-- ตัวอย่าง: 10:00:00-10:00:30, 10:00:10-10:00:40
CREATE TABLE BAAC_AGG_LOGIN_HOPPING_TB WITH (
    KAFKA_TOPIC = 'BAAC_AGG_LOGIN_HOPPING_TB',
    FORMAT = 'JSON'
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM BAAC_RAW_LOGIN_EVENTS_ST
WINDOW HOPPING (SIZE 30 SECONDS, ADVANCE BY 10 SECONDS)
GROUP BY USER_ID
EMIT CHANGES;

-- 2.3 SESSION WINDOW (Dynamic size based on inactivity)
-- Group logins within a session. Session closes if no activity for 30 seconds.
-- เหมาะสำหรับดูพฤติกรรมการใช้งานจริงของผู้ใช้
CREATE TABLE BAAC_AGG_LOGIN_SESSION_TB WITH (
    KAFKA_TOPIC = 'BAAC_AGG_LOGIN_SESSION_TB',
    FORMAT = 'JSON'
) AS
SELECT
    USER_ID,
    COUNT(*) AS LOGIN_COUNT,
    TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm:ss', 'UTC+7') AS START_TIME,
    TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm:ss', 'UTC+7') AS END_TIME
FROM BAAC_RAW_LOGIN_EVENTS_ST
WINDOW SESSION (30 SECONDS)
GROUP BY USER_ID
EMIT CHANGES;
