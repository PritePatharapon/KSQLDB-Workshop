--------------------------------------------------------------------------------------
-- MOCK DATA FOR WINDOW AGGREGATION
-- Stream: BAAC_RAW_LOGIN_EVENTS_ST
-- Concept: 
-- 1. Tumbling: 30s Fixed (No overlap)
-- 2. Hopping: 30s Size, 10s Advance (Overlap)
-- 3. Session: 30s Inactivity Timeout
--------------------------------------------------------------------------------------

-- ==========================================
-- SCENARIO 1: User_A (Test Tumbling vs Hopping)
-- ==========================================

-- Batch 1: วินาทีที่ 0-10
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('User_A', 'Web', 'SUCCESS');
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('User_A', 'Web', 'FAIL');

-- (คำแนะนำ: รอประมาณ 15 วินาที)

-- Batch 2: วินาทีที่ 15-25 (ยังอยู่ใน Window แรกของ Tumbling และ Hopping)
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('User_A', 'Web', 'SUCCESS');

-- (คำแนะนำ: รอจนข้ามวินาทีที่ 30 -> เริ่ม Window ใหม่ของ Tumbling)

-- Batch 3: วินาทีที่ 35+ (ขึ้น Window ใหม่ของ Tumbling แต่ Hopping ยังเห็นข้อมูล Batch 2 อยู่)
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('User_A', 'Web', 'SUCCESS');


-- ==========================================
-- SCENARIO 2: User_B (Test Session Window)
-- ==========================================

-- Session 1 Start: ยิงรัวๆ
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('User_B', 'App', 'SUCCESS');
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('User_B', 'App', 'SUCCESS');

-- (สำคัญมาก!: ต้องหยุดยิงเกิน 30 วินาที เพื่อให้ Session เก่าปิดตัวลง)

-- Session 2 Start: กลับมายิงใหม่ -> ต้องเกิดเป็น Session ใหม่ (Count เริ่มนับ 1 ใหม่)
INSERT INTO BAAC_RAW_LOGIN_EVENTS_ST (USER_ID, DEVICE_TYPE, LOGIN_STATUS) VALUES ('User_B', 'App', 'FAIL');
