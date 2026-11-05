/*
============================================================
PROJECT: Lending Club Loan Portfolio & Credit Risk Analysis
FILE: 02_data_profiling.sql

PURPOSE:
1. Understand the dataset's structure and size.
2. Examine missing and non-standard values.
3. Explore loan status and borrower characteristics.
4. Examine loan characteristics and credit variables.
5. Identify fields requiring cleaning or further validation.

SOURCE TABLE:
- staging.loan_raw

IMPORTANT:
- All source fields were imported as text.
- Literal 'NA' values are treated as missing during profiling.
- No source data is modified in this script.
============================================================
*/


-- =========================================================
-- 1. OVERALL DATASET SIZE
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT id) AS distinct_loan_ids
FROM staging.loan_raw;


-- =========================================================
-- 2. SOURCE TABLE COLUMN COUNT
-- =========================================================

SELECT
    COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'loan_raw';


-- =========================================================
-- 3. MISSINGNESS PROFILE ACROSS ALL COLUMNS
-- =========================================================

SELECT
    column_name,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE value IS NULL
           OR BTRIM(value) = ''
           OR UPPER(BTRIM(value)) = 'NA'
    ) AS missing_records,
    COUNT(*) FILTER (
        WHERE value IS NOT NULL
          AND BTRIM(value) <> ''
          AND UPPER(BTRIM(value)) <> 'NA'
    ) AS populated_records,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE value IS NULL
               OR BTRIM(value) = ''
               OR UPPER(BTRIM(value)) = 'NA'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS missing_percentage
FROM staging.loan_raw r
CROSS JOIN LATERAL
    JSONB_EACH_TEXT(TO_JSONB(r)) AS fields(column_name, value)
GROUP BY column_name
ORDER BY missing_records DESC, column_name;


-- =========================================================
-- 4. LOAN STATUS DISTRIBUTION
-- =========================================================

SELECT
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM staging.loan_raw
GROUP BY loan_status
ORDER BY loan_count DESC;


-- =========================================================
-- 5. LOAN TERM DISTRIBUTION
-- =========================================================

SELECT
    BTRIM(term) AS loan_term,
    COUNT(*) AS loan_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM staging.loan_raw
GROUP BY BTRIM(term)
ORDER BY loan_count DESC;


-- =========================================================
-- 6. LOAN GRADE DISTRIBUTION
-- =========================================================

SELECT
    grade,
    COUNT(*) AS loan_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM staging.loan_raw
GROUP BY grade
ORDER BY grade;


-- =========================================================
-- 7. SUB-GRADE DISTRIBUTION
-- =========================================================

SELECT
    sub_grade,
    COUNT(*) AS loan_count
FROM staging.loan_raw
GROUP BY sub_grade
ORDER BY sub_grade;


-- =========================================================
-- 8. LOAN PURPOSE DISTRIBUTION
-- =========================================================

SELECT
    purpose,
    COUNT(*) AS loan_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM staging.loan_raw
GROUP BY purpose
ORDER BY loan_count DESC;


-- =========================================================
-- 9. EMPLOYMENT LENGTH DISTRIBUTION
-- =========================================================

SELECT
    emp_length,
    COUNT(*) AS loan_count
FROM staging.loan_raw
GROUP BY emp_length
ORDER BY loan_count DESC;


-- =========================================================
-- 10. HOME OWNERSHIP DISTRIBUTION
-- =========================================================

SELECT
    home_ownership,
    COUNT(*) AS loan_count
FROM staging.loan_raw
GROUP BY home_ownership
ORDER BY loan_count DESC;


-- =========================================================
-- 11. INCOME FIELD PROFILE
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(NULLIF(BTRIM(annual_inc), '')) AS populated_records,
    MIN(
        NULLIF(BTRIM(annual_inc), 'NA')::NUMERIC
    ) AS minimum_income,
    MAX(
        NULLIF(BTRIM(annual_inc), 'NA')::NUMERIC
    ) AS maximum_income,
    ROUND(
        AVG(NULLIF(BTRIM(annual_inc), 'NA')::NUMERIC),
        2
    ) AS average_income,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY NULLIF(BTRIM(annual_inc), 'NA')::NUMERIC
    ) AS median_income
FROM staging.loan_raw
WHERE UPPER(BTRIM(annual_inc)) <> 'NA';


-- =========================================================
-- 12. INTEREST RATE FIELD PROFILE
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    MIN(
        REPLACE(BTRIM(int_rate), '%', '')::NUMERIC
    ) AS minimum_interest_rate,
    MAX(
        REPLACE(BTRIM(int_rate), '%', '')::NUMERIC
    ) AS maximum_interest_rate,
    ROUND(
        AVG(
            REPLACE(BTRIM(int_rate), '%', '')::NUMERIC
        ),
        2
    ) AS average_interest_rate,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY REPLACE(BTRIM(int_rate), '%', '')::NUMERIC
    ) AS median_interest_rate
FROM staging.loan_raw
WHERE int_rate IS NOT NULL
  AND BTRIM(int_rate) <> ''
  AND UPPER(BTRIM(int_rate)) <> 'NA';


-- =========================================================
-- 13. REVOLVING UTILISATION FIELD PROFILE
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE revol_util IS NULL
           OR BTRIM(revol_util) = ''
           OR UPPER(BTRIM(revol_util)) = 'NA'
    ) AS missing_records,
    MIN(
        REPLACE(BTRIM(revol_util), '%', '')::NUMERIC
    ) AS minimum_utilisation,
    MAX(
        REPLACE(BTRIM(revol_util), '%', '')::NUMERIC
    ) AS maximum_utilisation,
    ROUND(
        AVG(
            REPLACE(BTRIM(revol_util), '%', '')::NUMERIC
        ),
        2
    ) AS average_utilisation,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY REPLACE(BTRIM(revol_util), '%', '')::NUMERIC
    ) AS median_utilisation
FROM staging.loan_raw
WHERE revol_util IS NOT NULL
  AND BTRIM(revol_util) <> ''
  AND UPPER(BTRIM(revol_util)) <> 'NA';


-- =========================================================
-- 14. DATE FIELD COMPLETENESS
-- =========================================================

SELECT
    'issue_d' AS column_name,
    COUNT(*) AS total_records,
    COUNT(NULLIF(BTRIM(issue_d), '')) AS populated_records,
    COUNT(*) - COUNT(NULLIF(BTRIM(issue_d), '')) AS missing_records
FROM staging.loan_raw

UNION ALL

SELECT
    'earliest_cr_line',
    COUNT(*),
    COUNT(NULLIF(BTRIM(earliest_cr_line), '')),
    COUNT(*) - COUNT(NULLIF(BTRIM(earliest_cr_line), ''))
FROM staging.loan_raw

UNION ALL

SELECT
    'last_pymnt_d',
    COUNT(*),
    COUNT(NULLIF(BTRIM(last_pymnt_d), '')),
    COUNT(*) - COUNT(NULLIF(BTRIM(last_pymnt_d), ''))
FROM staging.loan_raw

UNION ALL

SELECT
    'next_pymnt_d',
    COUNT(*),
    COUNT(NULLIF(BTRIM(next_pymnt_d), '')),
    COUNT(*) - COUNT(NULLIF(BTRIM(next_pymnt_d), ''))
FROM staging.loan_raw;


-- =========================================================
-- 15. APPLICATION TYPE DISTRIBUTION
-- =========================================================

SELECT
    application_type,
    COUNT(*) AS loan_count
FROM staging.loan_raw
GROUP BY application_type
ORDER BY loan_count DESC;


-- =========================================================
-- 16. POLICY CODE DISTRIBUTION
-- =========================================================

SELECT
    policy_code,
    COUNT(*) AS loan_count
FROM staging.loan_raw
GROUP BY policy_code
ORDER BY loan_count DESC;