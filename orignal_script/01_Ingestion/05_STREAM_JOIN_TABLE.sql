--------------------------------------------- 05 STREAM JOIN TABLE ---------------------------------------------
-- Scenario: ต้องการ Enrich ข้อมูล Transaction ที่ไหลเข้ามา (Stream) ด้วยข้อมูลรายละเอียดบัญชี (Table)
-- Source Stream: BAAC_POC_MFEC_TRANSACTION_STG10 (จาก 02_STG_AND_REJ.sql - ตัวที่ Clean แล้ว)
-- Source Table: BAAC_POC_MFEC_ACCOUNT_TB (จาก 01_RAW.sql)
-- Goal: ทุก Transaction ที่เข้ามา จะได้เห็นชื่อบัญชีและประเภทบัญชีแปะไปด้วย

CREATE STREAM BAAC_POC_MFEC_ENRICHED_TXN_ST WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_ENRICHED_TXN_ST',
    FORMAT = 'JSON', 
    PARTITIONS = 1, REPLICAS = 1
) AS 
SELECT 
    A.STRUCT_KEY AS JOIN_KEY,
    T.TXN_ID AS TXN_ID,
    T.TXN_CODE AS TXN_CODE,
    T.TXN_AMT AS TXN_AMT,
    T.ACCOUNT_ID AS ACCOUNT_ID,
    A.ACCOUNT_NAME AS ACCOUNT_NAME,
    A.ACCOUNT_TYPE AS ACCOUNT_TYPE,
    A.ACCOUNT_BALANCE AS ACCOUNT_BALANCE
FROM BAAC_POC_MFEC_TRANSACTION_STG10 T 
LEFT JOIN BAAC_POC_MFEC_ACCOUNT_TB A   
ON STRUCT(ACCOUNT_ID := T.ACCOUNT_ID) = A.STRUCT_KEY 
EMIT CHANGES;
