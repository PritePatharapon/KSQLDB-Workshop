-----------------------------------------------------------
-- CLEANUP SCRIPT: 03_Analytics
-- Drop all streams/tables in this pipeline
-- NOTE: Does NOT delete Kafka Topics
-----------------------------------------------------------

-- 06 WINDOW AGGREGATION
DROP TABLE IF EXISTS BAAC_AGG_LOGIN_SESSION_TB;
DROP TABLE IF EXISTS BAAC_AGG_LOGIN_HOPPING_TB;
DROP TABLE IF EXISTS BAAC_AGG_LOGIN_TUMBLING_TB;
DROP STREAM IF EXISTS BAAC_RAW_LOGIN_EVENTS_ST;
