--------------------------------------------- 04 TABLE JOIN TABLE ---------------------------------------------
-- Scenario: ต้องการรวมข้อมูล Account (บัญชีเงินฝาก) เข้ากับข้อมูล Transaction เพื่อดูยอดคงเหลือรวมของลูกค้าแต่ละคน
-- โดยใช้ Table (BAAC_POC_MFEC_ACCOUNT_TB) Join กับ Table (BAAC_POC_MFEC_TRANSACTION_TB) ที่สร้างไว้ใน 01_RAW.sql
-- Goal: สร้าง Unified View ของลูกค้า

CREATE TABLE BAAC_POC_MFEC_ACCOUNT_TRANSACTION_VIEW_TB WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_ACCOUNT_TRANSACTION_VIEW_TB',
    FORMAT = 'AVRO',
    PARTITIONS = 1, REPLICAS = 1
) AS
SELECT
    A.STRUCT_KEY AS ACCOUNT_KEY,
    A.ACCOUNT_ID,
    A.ACCOUNT_NAME,
    A.ACCOUNT_TYPE,
    T.TXN_ID AS LATEST_TXN_ID,
    T.TXN_AMT AS LATEST_TXN_AMT,
    T.UPDATE_TS AS LAST_TXN_TIME
FROM BAAC_POC_MFEC_ACCOUNT_TB A
LEFT JOIN BAAC_POC_MFEC_TRANSACTION_TB T 
ON A.STRUCT_KEY = T.STRUCT_KEY -- Join ด้วย Key เดียวกัน (Account ID)
EMIT CHANGES;
