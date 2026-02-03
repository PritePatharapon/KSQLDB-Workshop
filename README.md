<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="#">
    <img src="https://img.icons8.com/fluency/96/server.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">KSQLDB Workshop</h3>

  <p align="center">
    Advanced Data Pipeline Workshop with KSQLDB
    <br />
    <a href="#getting-started"><strong>Explore Docs »</strong></a>
  </p>
</div>

<!-- BADGES -->
<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![KSQLDB](https://img.shields.io/badge/ksqlDB-0.28.2-000000?style=flat&logo=ksqldb&logoColor=white)](https://ksqldb.io/)
[![Kafka](https://img.shields.io/badge/Apache_Kafka-3.6.0-231F20?style=flat&logo=apache-kafka&logoColor=white)](https://kafka.apache.org/)

</div>


<!-- TABLE OF CONTENTS -->

## 🚀 Example Data Pipeline

### 1. Overview Data Pipeline
**คำอธิบาย:**
ภาพรวมของ Flow ข้อมูลใน Workshop นี้ จะเป็นการรับข้อมูล Transaction เข้ามา ทำการแปลงข้อมูล (Transform) ตรวจสอบความถูกต้อง (Validate) และส่งผลลัพธ์ออกไป

**Script:**
```sql
-- ดู Topic ทั้งหมดที่มีในระบบ เพื่อสำรวจ Source Data
SHOW TOPICS;
```

### 2. Create Source Stream and Table
**คำอธิบาย:**
การสร้าง Stream และ Table เพื่อ map เข้ากับ Kafka Topic ที่มีอยู่แล้ว เพื่อให้ ksqlDB สามารถอ่านข้อมูลได้

**Script:**
```sql
-- สร้าง Source Stream จาก Topic 'raw_transactions'
CREATE STREAM raw_txns (
    txn_id VARCHAR,
    amount DOUBLE,
    user_id VARCHAR
) WITH (
    KAFKA_TOPIC = 'raw_transactions',
    VALUE_FORMAT = 'JSON'
);
```

### 3. Data STG (Cast, Delimited, Field name)
**คำอธิบาย:**
ขั้นตอน Staging Data เพื่อทำความสะอาดและจัดรูปแบบข้อมูล:
*   **Cast**: เปลี่ยน type เช่น String เป็น Int
*   **Delimited**: แยกข้อมูลที่ติดกัน
*   **Field name**: เปลี่ยนชื่อ Column ให้สื่อความหมาย

**Script:**
```sql
-- สร้าง Stream ใหม่ที่ Clean ข้อมูลแล้ว
CREATE STREAM stg_txns AS
SELECT 
    CAST(txn_id AS INT) AS id,
    amount,
    UCASE(user_id) AS user_account_id
FROM raw_txns
EMIT CHANGES;
```

### 4. Data STG ksqlDB Join
**คำอธิบาย:**
การรวมข้อมูล (Join) ระหว่าง Data Sources เพื่อเติมเต็มข้อมูลให้สมบูรณ์ (Enrichment) โดยมี 3 รูปแบบหลัก: Stream-Stream, Stream-Table, Table-Table

**Script:**
```sql
-- ตัวอย่าง Stream-Table Join (Enrich Transaction ด้วย User Profile)
CREATE STREAM enriched_txns AS
SELECT 
    t.id AS txn_id,
    t.amount,
    u.name AS user_name
FROM stg_txns t
LEFT JOIN user_profiles u ON t.user_account_id = u.user_id
EMIT CHANGES;
```

### 5. Data STG Window Aggregate
**คำอธิบาย:**
การคำนวณผลลัพธ์โดยแบ่งช่วงเวลา (Windowing) เช่น "ยอดรวมทุกๆ 5 นาที"

**Script:**
```sql
-- นับจำนวน Transaction ทุกๆ 1 นาที (Tumbling Window)
SELECT 
    user_account_id,
    COUNT(*) AS txn_count
FROM stg_txns
WINDOW TUMBLING (SIZE 1 MINUTE)
GROUP BY user_account_id
EMIT CHANGES;
```

### 6. UDF (User Defined Functions)
**คำอธิบาย:**
การเรียกใช้ฟังก์ชันพิเศษที่เราเขียน Java Code ขึ้นมาเอง เพื่อทำ Logic ที่ซับซ้อนซึ่ง SQL ธรรมดาทำไม่ได้

**Script:**
```sql
-- ตัวอย่างการใช้ UDF (สมมติชื่อ formula_x)
SELECT 
    id, 
    formula_x(amount) AS calculated_value 
FROM stg_txns 
EMIT CHANGES;
```

### 7. Data STG Reject
**คำอธิบาย:**
การกรองข้อมูลที่ผิดปกติหรือไม่ต้องการ แยกออกไปลง Stream/Table อื่น (Filter Logic)

**Script:**
```sql
-- แยกข้อมูลที่ Amount น้อยกว่า 0 ไปลง table reject
CREATE STREAM rejected_txns AS
SELECT * 
FROM stg_txns 
WHERE amount < 0
EMIT CHANGES;
```

### 8. SVC (Masking field)
**คำอธิบาย:**
การปกปิดข้อมูลสำคัญ (PII) ก่อนนำไปใช้งานต่อ เพื่อความปลอดภัย (Data Privacy)

**Script:**
```sql
-- Masking เลขบัตรเครดิต
SELECT 
    id, 
    MASK(credit_card_number) AS masked_card 
FROM stg_sensitive_data 
EMIT CHANGES;
```

### 9. Logging error, Error Handling
**คำอธิบาย:**
การตรวจสอบ Error ที่เกิดขึ้นใน System เพื่อใช้ในการ Debug และ Monitor Pipeline

**Script:**
```sql
-- ดู Processing Log ของ ksqlDB
SELECT * FROM ksql_processing_log 
WHERE type = 'error' 
EMIT CHANGES;
```

### 10. Monitoring Grafana, C3
**คำอธิบาย:**
การดู Dashboard เพื่อ Monitor Throughput และ Latency ของ Pipeline

**Script:**
```bash
# (Command line) ตรวจสอบ Consumer Group Lag
kafka-consumer-groups --bootstrap-server broker:9092 --describe --all-groups
```

### 11. Technical Column (Optional)
**คำอธิบาย:**
การดึงข้อมูล System Columns มาใช้งาน เช่น เวลาที่ข้อมูลเข้า Kafka (Rowtime)

**Script:**
```sql
-- ดึง ROWTIME และ ROWKEY มาแสดง
SELECT 
    ROWTIME,
    ROWKEY,
    id,
    amount 
FROM stg_txns 
EMIT CHANGES;
```

---

## 🔌 Optional - Kafka Connect

### Kafka Connect Integration
**คำอธิบาย:**
การใช้งาน Kafka Connect เพื่อดึงข้อมูลจาก Database ภายนอกเข้ามา (Source) หรือส่งข้อมูลออกไป (Sink)

**Script:**
```sql
-- สร้าง Connector ผ่าน ksqlDB
CREATE SOURCE CONNECTOR jdbc_source WITH (
  'connector.class' = 'io.confluent.connect.jdbc.JdbcSourceConnector',
  'connection.url'  = 'jdbc:postgresql://db:5432/mydb',
  'topic.prefix'    = 'postgres-',
  'table.whitelist' = 'users'
);
```