--------------------------------------------- 05 STREAM JOIN TABLE ---------------------------------------------
-- Scenario: ต้องการ Enrich ข้อมูล Transaction ที่ไหลเข้ามา (Stream) ด้วยข้อมูลรายละเอียดบัญชี (Table)
-- Source Stream: BAAC_POC_MFEC_TRANSACTION_STG10 (จาก 02_STG_AND_REJ.sql - ตัวที่ Clean แล้ว)
-- Source Table: BAAC_POC_MFEC_ACCOUNT_TB (จาก 01_RAW.sql)
-- Goal: ทุก Transaction ที่เข้ามา จะได้เห็นชื่อบัญชีและประเภทบัญชีแปะไปด้วย

CREATE STREAM BAAC_POC_MFEC_ENRICHED_TXN_ST WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_ENRICHED_TXN_ST',
    FORMAT = 'AVRO', 
    PARTITIONS = 1, REPLICAS = 1
) AS 
SELECT 
    T.TXN_ID,
    T.TXN_CODE,
    T.TXN_AMT,
    T.ACCOUNT_ID,
    A.ACCOUNT_NAME,
    A.ACCOUNT_TYPE,
    A.ACCOUNT_BALANCE
FROM BAAC_POC_MFEC_TRANSACTION_STG10 T -- ใช้ STG Stream (Clean)
LEFT JOIN BAAC_POC_MFEC_ACCOUNT_TB A   -- Join กับ Table
ON STRUCT(ACCOUNT_ID := T.ACCOUNT_ID) = A.STRUCT_KEY -- ต้อง Match Key ให้ตรงกัน
EMIT CHANGES;
