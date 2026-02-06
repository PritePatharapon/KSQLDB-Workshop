---Step 4 Insert and Select Data
INSERT INTO
INSERT INTO
INSERT INTO

SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM CDC_MF_TXN_STG_ST_<USER>

SET 'auto.offset.reset' = 'earliest';

-- Select Reject Data
Select * From CDC_MF_TXN_STG_REJ_ST_<USER>