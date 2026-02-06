---Step 3 Insert and Select Data within window time
INSERT INTO
INSERT INTO
INSERT INTO

SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER>

---Step 4 Insert and Select Data without window time
INSERT INTO
INSERT INTO
INSERT INTO

SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_DB_MASTER_ACC_STG_JOIN_STREAM_STREAM_ST_<USER>