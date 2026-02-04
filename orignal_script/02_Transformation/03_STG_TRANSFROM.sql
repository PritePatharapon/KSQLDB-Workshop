--------------------------------------------- 03 TRANSFORM (RAW STRING -> STRUCT) ---------------------------------------------
-- Scenario: รับข้อมูล Raw Data เข้ามาเป็น String ยาวๆ (Pipe Delimited Format) ผ่าน Topic 'BAAC_RAW_PIPE_DATA'
-- ตัวอย่างข้อมูล: "TXN1001|CW|5000|ACC001|2023-10-27"
-- Goal: 
-- 1. อ่านเป็น String (CAST)
-- 2. ตัดคำด้วย Pipe '|' (DELIMITED)
-- 3. ตั้งชื่อ Field ใหม่ (FIELD NAME)
-- 4. จัด Format ให้เป็น STRUCT

-- 1. สร้าง Stream รับ Raw String (KAFKA_TOPIC มีข้อมูลอยู่จริง หรือ Mock ขึ้นมา)
CREATE STREAM BAAC_RAW_STRING_INPUT_ST (
    raw_message VARCHAR
) WITH (
    KAFKA_TOPIC = 'BAAC_RAW_PIPE_DATA',
    VALUE_FORMAT = 'KAFKA', -- รับเป็น Byte/String ดิบๆ ไม่ใช่ AVRO/JSON
    PARTITIONS = 1,
    REPLICAS = 1
);

-- 2. Transform: Split, Cast, Rename -> Create Structured Stream
CREATE STREAM BAAC_POC_MFEC_TRANSFORMED_ST WITH (
    KAFKA_TOPIC = 'BAAC_POC_MFEC_TRANSFORMED_ST',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 1, REPLICAS = 1
) AS
SELECT
    -- 2.1 ใช้ SPLIT เพื่อแยก String ด้วย '|' (Delimited)
    SPLIT(raw_message, '|') AS arr_data,
    
    -- 2.2 ดึง Data จาก Array มาตั้งชื่อ Field ใหม่ (Field Name)
    SPLIT(raw_message, '|')[1] AS txn_id,
    
    -- 2.3 แปลง Type (CAST)
    CAST(SPLIT(raw_message, '|')[3] AS DOUBLE) AS txn_amt,
    
    -- 2.4 จัดลง Struct
    STRUCT(
        txn_code := SPLIT(raw_message, '|')[2],
        account_id := SPLIT(raw_message, '|')[4],
        txn_date := SPLIT(raw_message, '|')[5]
    ) AS txn_details
FROM BAAC_RAW_STRING_INPUT_ST
EMIT CHANGES;
