--------------------------------------------------------------------------------------
-- MOCK DATA FOR TRANSFORM PIPELINE
-- Stream: BAAC_RAW_STRING_INPUT_ST
--------------------------------------------------------------------------------------

-- Scenario: Data เข้ามาเป็น Pipe Delimited String
-- Format: TXN_ID|TXN_CODE|txn_amt|ACCOUNT_ID|txn_date

INSERT INTO BAAC_RAW_STRING_INPUT_ST (raw_message)
VALUES ('TXN_CSV_01|pay|1500.50|ACC888|2024-02-01');

INSERT INTO BAAC_RAW_STRING_INPUT_ST (raw_message)
VALUES ('TXN_CSV_02|dep|9000.00|ACC999|2024-02-02');

INSERT INTO BAAC_RAW_STRING_INPUT_ST (raw_message)
VALUES ('TXN_CSV_03|wth|400.00|ACC888|2024-02-03');
