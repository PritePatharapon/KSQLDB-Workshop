-- Insert Data 
INSERT INTO
INSERT INTO
INSERT INTO

SET 'auto.offset.reset' = 'earliest';

-- Select Accept Data 
SELECT * FROM MB_LOGIN_EVENTS_STG_TUMBLING_ST_<USER>

SET 'auto.offset.reset' = 'earliest';

-- Select Reject Data
Select * From MB_LOGIN_EVENTS_STG_HOPPING_TB_<USER>

SET 'auto.offset.reset' = 'earliest';

-- Select Reject Data
Select * From MB_LOGIN_EVENTS_STG_SESSION_TB_<USER>
