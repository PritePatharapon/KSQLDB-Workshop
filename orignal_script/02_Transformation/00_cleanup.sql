-----------------------------------------------------------
-- CLEANUP SCRIPT: 02_Transformation
-- Drop all streams/tables in this pipeline
-- NOTE: Does NOT delete Kafka Topics
-----------------------------------------------------------

-- 03 STG TRANSFORM
DROP STREAM IF EXISTS BAAC_POC_MFEC_TRANSFORMED_ST;
DROP STREAM IF EXISTS BAAC_RAW_STRING_INPUT_ST;
