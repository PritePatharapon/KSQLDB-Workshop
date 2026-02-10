-- Monitor Source Stream
SELECT * FROM CDC_MF_TXN_RAW_ST_<USER> EMIT CHANGES;

-- Monitor Valid Data Stream (Staging)
SELECT * FROM CDC_MF_TXN_STG_ST_<USER> EMIT CHANGES;

-- Monitor Rejected Data Stream
SELECT * FROM CDC_MF_TXN_STG_REJ_ST_<USER> EMIT CHANGES;

-- Scenario 1: Normal Transaction (ATM) -> Should go to STG
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) VALUES ('TXN1001|DEPOSIT|D01|5000.00|ACC001|2024-02-09 10:00:00|ATM|2024-02-09 10:00:05');

-- Scenario 2: Rejected Transaction (Restricted ID '000000' + Mobile) -> Should go ONLY to REJ (Filtered from STG)
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) VALUES ('000000|TEST|X00|0.00|ACC999|2024-02-09 10:10:00|Mobile|2024-02-09 10:10:05');