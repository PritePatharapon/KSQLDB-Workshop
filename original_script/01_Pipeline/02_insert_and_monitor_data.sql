-- Monitor Source Stream
SELECT * FROM CDC_MF_TXN_RAW_ST_<USER> EMIT CHANGES;

-- Monitor Valid Data Stream (Staging)
SELECT * FROM CDC_MF_TXN_STG_ST_<USER> EMIT CHANGES;

-- Monitor Rejected Data Stream
SELECT * FROM CDC_MF_TXN_STG_REJ_ST_<USER> EMIT CHANGES;

-- Scenario 1: Normal Transaction (ATM) -> Should go to STG
-- Format: TXN_ID|TXN_TYPE|TXN_CODE|TXN_AMT|ACC_NO|TXN_DT|CHANNEL|UPDATE_TS
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) VALUES ('TXN1001|DEPOSIT|D01|5000.00|ACC001|2024-02-09 10:00:00|ATM|2024-02-09 10:00:05');

-- Scenario 2: Mobile Transaction (Valid ID) -> Should go to STG *AND* REJ (Based on current logic where Mobile goes to REJ, and Valid ID + Mobile passes STG filter)
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) VALUES ('TXN1002|TRANSFER|T01|1500.00|ACC001|2024-02-09 10:05:00|Mobile|2024-02-09 10:05:05');

-- Scenario 3: Rejected Transaction (Restricted ID '000000' + Mobile) -> Should go ONLY to REJ (Filtered from STG)
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) VALUES ('000000|TEST|X00|0.00|ACC999|2024-02-09 10:10:00|Mobile|2024-02-09 10:10:05');

-- Scenario 4: Restricted ID '999999' but NOT Mobile (e.g. Branch) -> Should go to STG (Because OR condition: Channel != Mobile is True)
INSERT INTO CDC_MF_TXN_RAW_ST_<USER> (raw_message) VALUES ('999999|ADMIN|A01|0.00|ACC999|2024-02-09 10:15:00|Branch|2024-02-09 10:15:05');