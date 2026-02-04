--------------------------------------------- 04 TABLE JOIN TABLE ---------------------------------------------
-- Scenario: ต้องการรวมข้อมูล Account (บัญชีเงินฝาก) เข้ากับข้อมูล Transaction เพื่อดูยอดคงเหลือรวมของลูกค้าแต่ละคน
-- โดยใช้ Table (BAAC_POC_MFEC_ACCOUNT_TB) Join กับ Table (BAAC_POC_MFEC_TRANSACTION_TB)
-- Goal: สร้าง Unified View ของลูกค้า (Account 1 คน มี Transaction ล่าสุดอะไรบ้าง)

-- Step 1: สร้าง Helper Table เพื่อเก็บ Latest Transaction ของแต่ละ Account
-- ต้อง Group By ให้ Key เป็น STRUCT<ACCOUNT_ID> เหมือนกับ BAAC_POC_MFEC_ACCOUNT_TB ถึงจะ Join กันได้
CREATE TABLE BAAC_POC_MFEC_LATEST_TXN_BY_ACC_TB WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_LATEST_TXN_BY_ACC_TB',
    FORMAT = 'JSON',
    PARTITIONS = 1, REPLICAS = 1
) AS
SELECT
    STRUCT(ACCOUNT_ID := ACCOUNT_ID) AS STRUCT_KEY,
    LATEST_BY_OFFSET(TXN_ID) AS LATEST_TXN_ID,
    LATEST_BY_OFFSET(TXN_AMT) AS LATEST_TXN_AMT,
    LATEST_BY_OFFSET(UPDATE_TS) AS LAST_TXN_TIME
FROM BAAC_POC_MFEC_TRANSACTION_ST
GROUP BY STRUCT(ACCOUNT_ID := ACCOUNT_ID)
EMIT CHANGES;

-- Step 2: Main Join (Table-Table Join on PK)
-- ตอนนี้ Table T (BAAC_POC_MFEC_LATEST_TXN_BY_ACC_TB) มี Key เป็น Account ID แล้ว จึง Join ได้
CREATE TABLE BAAC_POC_MFEC_ACCOUNT_TRANSACTION_VIEW_TB WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_ACCOUNT_TRANSACTION_VIEW_TB',
    FORMAT = 'JSON',
    PARTITIONS = 1, REPLICAS = 1
) AS
SELECT
    A.STRUCT_KEY AS ACCOUNT_KEY,
    A.ACCOUNT_ID,
    A.ACCOUNT_NAME,
    A.ACCOUNT_TYPE,
    T.LATEST_TXN_ID,
    T.LATEST_TXN_AMT,
    T.LAST_TXN_TIME
FROM BAAC_POC_MFEC_ACCOUNT_TB A
LEFT JOIN BAAC_POC_MFEC_LATEST_TXN_BY_ACC_TB T 
ON A.STRUCT_KEY = T.STRUCT_KEY 
EMIT CHANGES;
