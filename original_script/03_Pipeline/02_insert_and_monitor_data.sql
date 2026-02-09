-- Monitor Tumbling Window (Fixed 30s non-overlapping)
SELECT * FROM MB_LOGIN_EVENTS_STG_TUMBLING_ST_<USER> EMIT CHANGES;

-- Monitor Hopping Window (30s window, hop every 10s)
SELECT * FROM MB_LOGIN_EVENTS_STG_HOPPING_TB_<USER> EMIT CHANGES;

-- Monitor Session Window (Group events with gap < 30s)
SELECT * FROM MB_LOGIN_EVENTS_STG_SESSION_TB_<USER> EMIT CHANGES;

-- Batch 1: Start 3 events quickly
INSERT INTO MB_LOGIN_EVENTS_RAW_ST_<USER> (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('USER01', 'iOS', 'SUCCESS');
INSERT INTO MB_LOGIN_EVENTS_RAW_ST_<USER> (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('USER01', 'iOS', 'FAIL');
INSERT INTO MB_LOGIN_EVENTS_RAW_ST_<USER> (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('USER02', 'Android', 'SUCCESS');

-- Wait 15 seconds (Simulated)
-- INSERT INTO MB_LOGIN_EVENTS_RAW_ST_<USER> ... 

-- Batch 2: Trigger Update (These will fall into same Tumbling window if within 30s of start)
INSERT INTO MB_LOGIN_EVENTS_RAW_ST_<USER> (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('USER01', 'iOS', 'SUCCESS');

-- Expected: 
-- Tumbling: USER01 Count = 3
-- Hopping: updates every 10s
-- Session: USER01 session continues (count 3) because gap < 30s
