---------------------------------------------STG----------------------------------------------------
-- 1. Create Staging Stream (Clean Data)
-- Filter Logic:
-- 1. Valid Amount: กรองเอาเฉพาะรายการที่ยอดเงิน (TXN_AMT) มากกว่าหรือเท่ากับ 0
-- 2. Ignore Deletes: ไม่เอารายการที่เป็นการลบข้อมูล (__OP != 'd') จากระบบต้นทาง (CDC)
-- Transformation:
-- - ทำ UCASE(TXN_CODE) เพื่อให้ Code เป็นตัวใหญ่ทั้งหมด

CREATE STREAM BAAC_POC_MFEC_TRANSACTION_STG10 WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_TRANSACTION_STG10',
    FORMAT = 'AVRO',
    PARTITIONS = 1,
    REPLICAS = 1
) AS
SELECT
    STRUCT_KEY,
    TXN_ID,
    UCASE(TXN_CODE) AS TXN_CODE, 
    TXN_AMT,
    TXN_TYPE,
    ACCOUNT_ID,
    TXN_AMOUNT,
    TXN_TS,
    UPDATE_TS
FROM BAAC_POC_MFEC_TRANSACTION_ST
WHERE TXN_AMT >= 0 
  AND __OP != 'd'
EMIT CHANGES;

---------------------------------------------REJECT-------------------------------------------------
-- 2. Create Reject Stream (Log Error Transactions)
-- Filter Logic:
-- - ดักจับเฉพาะรายการที่ยอดเงินติดลบ (TXN_AMT < 0) เพื่อแยกไปตรวจสอบ

CREATE STREAM BAAC_POC_MFEC_TRANSACTION_STG10_REJ WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_TRANSACTION_STG10_REJ',
    FORMAT = 'AVRO',
    PARTITIONS = 1,
    REPLICAS = 1
) AS
SELECT
    STRUCT_KEY,
    TXN_ID,
    TXN_CODE,
    TXN_AMT,
    ACCOUNT_ID,
    'INVALID_AMOUNT_NEGATIVE' AS REJECT_REASON,
    UPDATE_TS
FROM BAAC_POC_MFEC_TRANSACTION_ST
WHERE TXN_AMT < 0
  AND __OP != 'd'
EMIT CHANGES;
