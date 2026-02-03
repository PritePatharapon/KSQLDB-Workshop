--------------------------------------------- 07 SVC MASKING ---------------------------------------------
-- Scenario: สร้าง Service Stream สำหรับให้ Downstream นำไปใช้งาน โดยต้องทำการ Mask Data ที่เป็น PII 
-- Source: BAAC_POC_MFEC_ENRICHED_TXN_ST (จากไฟล์ 05_STREAM_JOIN_TABLE.sql)
-- Masking Logic:
-- 1. Account Name: แสดงแค่ 3 ตัวหน้า ที่เหลือเป็น X (MASK_KEEP_LEFT)
-- 2. Transaction Amount: ถ้าเกิน 100,000 ให้โชว์แค่ 99999 (Example Logic) หรือทำเป็นความลับ
-- 3. Account ID: ปิด 4 ตัวท้าย (MASK_KEEP_RIGHT หรือ Substring)

CREATE STREAM BAAC_SVC_MASKED_TXN_ST WITH (
    KAFKA_TOPIC = 'BAAC_SVC_MASKED_TXN_ST',
    FORMAT = 'AVRO',
    PARTITIONS = 1, REPLICAS = 1
) AS
SELECT
    TXN_ID,
    TXN_CODE,
    
    -- Mask Account ID: แสดงเฉพาะ 4 ตัวหน้า (ACC0XXXX)
    MASK_KEEP_LEFT(ACCOUNT_ID, 4, 'x') AS MASKED_ACCOUNT_ID,
    
    -- Mask Account Name: แสดงเฉพาะ 3 ตัวแรก (Som***)
    MASK_KEEP_LEFT(ACCOUNT_NAME, 3, '*') AS MASKED_ACC_NAME,
    
    ACCOUNT_TYPE,
    TXN_AMT,
    ACCOUNT_BALANCE
FROM BAAC_POC_MFEC_ENRICHED_TXN_ST
EMIT CHANGES;
