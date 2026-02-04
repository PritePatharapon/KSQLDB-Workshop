
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
เป็น pipeline แสดงตัวอย่างการใช้ ksqlDB สร้าง Data Pipeline จะมีทั้งหมด 3 Pipeline ดังนี้

1. Ingestion
    * เป็นเส้นเกี่ยวกับการทำ filter ข้อมูล และแสดงตัวอย่างการ join ข้อมูล ในรูปแบบต่างๆ ร่วมถึงการทำ masking ข้อมูล
2. Transformation
    * เป็นเส้นเกี่ยวกับการทำ delimited, cast, กำหนด field ให้ ข้อมูล
3. Analytics
    * เป็นเส้นเกี่ยวกับการทำ window aggregate

---

### 2. Preparation (IMPORTANT!)
ก่อนเริ่มรัน Workshop จะต้องทำการเตรียมไฟล์ Script ให้พร้อมใช้งานสำหรับ User ของคุณ โดยการรัน Script เพื่อเปลี่ยนชื่อ Resource (Stream/Table/Topic) ทั้งหมดให้มี Suffix เป็นชื่อของคุณ (ป้องกันการชนกันกับคนอื่น)

**คำสั่ง:**
```bash
# พิมพ์คำสั่งนี้ใน Terminal (เปลี่ยน <your_name> เป็นชื่อของคุณ หรือ Suffix ที่ต้องการ)
# ตัวอย่าง: ./prepare_workshop.sh user01
./prepare_workshop.sh <your_name>
```

**ผลลัพธ์:**
1. Folder `workshop_script/` จะถูกสร้างขึ้นใหม่
2. ไฟล์ SQL ทั้งหมดจะถูก Copy และเปลี่ยนชื่อ Resource ให้ต่อท้ายด้วย `_<your_name>`
    * ตัวอย่าง: `BAAC_POC_MFEC_ACCOUNT_ST` -> `BAAC_POC_MFEC_ACCOUNT_ST_user01`
3. ไฟล์ Mock Data ใน `workshop_script/mock_data/` ก็จะถูกเปลี่ยนชื่อให้ตรงกันพร้อมใช้งาน

> **Note:** ในคู่มือนี้จะใช้ Suffix เป็น **`_user01`** ในตัวอย่าง

---

### 3. Workshop Execution Steps
ทำตามขั้นตอนทีละ Pipeline โดย **Copy Code จากไฟล์ใน workshop_script** ไปรัน

#### 🔍 3.1 Pipeline 1: Ingestion
> **Goal:** นำเข้าข้อมูล Raw Data, กรองข้อมูล (Stage/Reject), ทำการ Join ข้อมูล (Stream-Stream, Stream-Table, Table-Table) และ Masking Field Sensitive

**Step 1: Create Streams & Tables**
รันคำสั่งสร้าง Resource ให้ครบตามลำดับไฟล์:
1. `01_Ingestion/01_RAW.sql` (สร้าง Table หลัก Account, Transaction)
2. `01_Ingestion/02_STG_AND_REJ.sql` (แยก Transaction ดี/เสีย)
3. `01_Ingestion/03_STREAM_JOIN_STREAM.sql` (Stream Join Stream)
4. `01_Ingestion/04_TABLE_JOIN_TABLE.sql` (Table Join Table)
5. `01_Ingestion/05_STREAM_JOIN_TABLE.sql` (Transaction Enriched with Account)
6. `01_Ingestion/06_SVC_MASKING.sql` (Final Output with Masking)

**Step 2: Monitor Output (Select)**
เปิดหน้า Terminal/KSQLDB ใหม่ แล้วรันคำสั่งนี้ค้างไว้เพื่อดูผลลัพธ์ปลายทาง:
```sql
-- ดูข้อมูลปลายทางที่ Masking เรียบร้อยแล้ว (อย่าลืมเปลี่ยน Suffix)
SET 'auto.offset.reset' = 'earliest';
SELECT * FROM BAAC_SVC_MASKED_TXN_ST_user01 EMIT CHANGES;
```

**Step 3: Insert Mock Data**
เปิด Terminal ใหม่ (หรือใช้ Tool) รันคำสั่ง Insert ข้อมูลจำลอง:
*ใช้ไฟล์:* `workshop_script/mock_data/01_main_flow_mock.sql`

```sql
-- ตัวอย่าง Insert Account
INSERT INTO BAAC_POC_MFEC_ACCOUNT_ST_user01 (...) VALUES (...);

-- ตัวอย่าง Insert Transaction (จะเห็นข้อมูลไหลเข้าจอ Monitor ทันที)
INSERT INTO BAAC_POC_MFEC_TRANSACTION_ST_user01 (...) VALUES (...);
```

---

#### 🛠 3.2 Pipeline 2: Transformation
> **Goal:** แปลงข้อมูลจาก String ยาวๆ (Pipe Delimited) ให้เป็น Structured Data

**Step 1: Create Stream**
รันคำสั่งจากไฟล์:
1. `02_Transformation/03_STG_TRANSFROM.sql`

**Step 2: Monitor Output (Select)**
```sql
SELECT * FROM BAAC_POC_MFEC_TRANSFORMED_ST_user01 EMIT CHANGES;
```

**Step 3: Insert Mock Data**
*ใช้ไฟล์:* `workshop_script/mock_data/02_transform_mock.sql`
```sql
-- ยิงข้อมูล string ยาวๆ เข้าไป เช่น "TXN001|DEBIT|500"
INSERT INTO BAAC_RAW_STRING_INPUT_ST_user01 ...
```

---

#### 📊 3.3 Pipeline 3: Analytics (Window Aggregation)
> **Goal:** คำนวณยอดทางสถิติในช่วงเวลาต่างๆ (Tumbling, Hopping, Session)

**Step 1: Create Window Tables**
รันคำสั่งจากไฟล์:
1. `03_Analytics/06_WINDOW_AGGREGATION.sql`

**Step 2: Monitor Output (Select)**
เลือกดูผลลัพธ์ตามประเภท Window ที่สนใจ:

*แบบ Session Window (พฤติกรรม User)*
```sql
SELECT * FROM BAAC_AGG_LOGIN_SESSION_TB_user01 EMIT CHANGES;
```

**Step 3: Insert Mock Data**
*ใช้ไฟล์:* `workshop_script/mock_data/03_window_mock.sql`

> **Note:** สำหรับ Session Window ต้องลองยิงข้อมูลเว้นช่วงเกิน 30 วินาที เพื่อให้ Window ตัดรอบ
```sql
-- ยิง Login Event ของ User B (Start Session)
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST_user01 ...
-- (รอ 30+ วินาที)
-- ยิง Login Event ใหม่ (Start New Session)
```

---

## 🧹 Cleanup Steps
เมื่อจบ Workshop ให้ทำการลบ Reosurce ตามลำดับดังนี้:

**1. Drop KSQLDB Streams/Tables**
รันคำสั่ง SQL จากไฟล์ Cleanup ใน KSQLDB Editor (เพื่อลบ Table/Stream ใน Memory ของ KSQLDB)
*   `01_Ingestion/00_cleanup.sql`
*   `02_Transformation/00_cleanup.sql`
*   `03_Analytics/00_cleanup.sql`

**2. Delete Underlying Kafka Topics (Optional)**
หากต้องการลบข้อมูล Kafka Topic จริงๆ (Clean Storage) ให้รัน Shell Script นี้:
```bash
# เปลี่ยน user01 เป็นชื่อของคุณ
./delete_topics_by_suffix.sh user01
```