/*
============================================================
PROJECT: Lending Club Loan Portfolio & Credit Risk Analysis
FILE: 01_data_loading_and_setup.sql

PURPOSE:
1. Establish the project schemas.
2. Confirm that the imported raw dataset exists.
3. Inspect the source table structure.
4. Confirm the basic size and record identifiers.

SOURCE FILES:
- loan.csv
- Data_Dictionary.xlsx

SOURCE TABLE:
- staging.loan_raw

IMPORTANT:
- The CSV was imported through pgAdmin.
- This script does not re-import the source data.
- staging.loan_raw is preserved unchanged.
============================================================
*/


-- =========================================================
-- 1. CREATE PROJECT SCHEMAS
-- =========================================================

CREATE SCHEMA IF NOT EXISTS staging;

CREATE SCHEMA IF NOT EXISTS analytics;


-- =========================================================
-- 2. CONFIRM SOURCE TABLE EXISTS
-- =========================================================

SELECT
    to_regclass('staging.loan_raw') AS source_table;


-- =========================================================
-- 3. INSPECT SOURCE TABLE STRUCTURE
-- =========================================================

SELECT
    column_name,
    data_type,
    character_maximum_length,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'loan_raw'
ORDER BY ordinal_position;


-- =========================================================
-- 4. CHECK SOURCE RECORD COUNT
-- =========================================================

SELECT
    COUNT(*) AS total_records
FROM staging.loan_raw;


-- =========================================================
-- 5. CHECK LOAN IDENTIFIER COMPLETENESS
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(id) AS populated_ids,
    COUNT(DISTINCT id) AS distinct_ids,
    COUNT(*) - COUNT(id) AS missing_ids,
    COUNT(id) - COUNT(DISTINCT id) AS duplicate_id_count
FROM staging.loan_raw;


-- =========================================================
-- 6. CHECK SOURCE TABLE SIZE
-- =========================================================

SELECT
    pg_size_pretty(
        pg_total_relation_size('staging.loan_raw')
    ) AS source_table_size;