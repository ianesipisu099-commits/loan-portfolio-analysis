
/*
============================================================
PROJECT: Lending Club Loan Portfolio & Credit Risk Analysis
FILE: 04_data_quality_validation.sql

PURPOSE:
1. Validate record and identifier reconciliation.
2. Confirm the clean table structure.
3. Check missing values and data types.
4. Validate date transformations and chronology.
5. Check loan funding and payment consistency.
6. Examine key financial relationships.
7. Confirm that the cleaned dataset is suitable for analysis.

SOURCE TABLE:
- staging.loan_raw

CLEAN TABLE:
- analytics.loan_clean

EXPECTED RECORD COUNT:
- 39,717

EXPECTED CLEAN COLUMNS:
- 42

IMPORTANT:
- These are validation queries.
- They do not modify either table.
- Small rounding differences are not automatically
  treated as data errors.
============================================================
*/


-- =========================================================
-- 1. RECORD COUNT RECONCILIATION
-- =========================================================

SELECT
    (SELECT COUNT(*) FROM staging.loan_raw) AS raw_records,
    (SELECT COUNT(*) FROM analytics.loan_clean) AS clean_records,
    (SELECT COUNT(*) FROM staging.loan_raw)
      - (SELECT COUNT(*) FROM analytics.loan_clean)
      AS record_difference;


-- =========================================================
-- 2. LOAN ID RECONCILIATION
-- =========================================================

SELECT
    COUNT(*) AS matching_ids
FROM staging.loan_raw r
INNER JOIN analytics.loan_clean c
    ON r.id = c.id;


SELECT
    COUNT(*) AS raw_ids_missing_from_clean
FROM staging.loan_raw r
LEFT JOIN analytics.loan_clean c
    ON r.id = c.id
WHERE c.id IS NULL;


SELECT
    COUNT(*) AS clean_ids_missing_from_raw
FROM analytics.loan_clean c
LEFT JOIN staging.loan_raw r
    ON c.id = r.id
WHERE r.id IS NULL;


-- =========================================================
-- 3. CLEAN TABLE ID INTEGRITY
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(id) AS populated_ids,
    COUNT(DISTINCT id) AS distinct_ids,
    COUNT(*) - COUNT(id) AS missing_ids,
    COUNT(id) - COUNT(DISTINCT id) AS duplicate_id_count
FROM analytics.loan_clean;


-- =========================================================
-- 4. CLEAN TABLE COLUMN COUNT AND DATA TYPES
-- =========================================================

SELECT
    COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'loan_clean';


SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'loan_clean'
ORDER BY ordinal_position;


-- =========================================================
-- 5. MISSING VALUE PROFILE
-- =========================================================

SELECT
    column_name,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE value IS NULL
    ) AS missing_records,
    COUNT(*) FILTER (
        WHERE value IS NOT NULL
    ) AS populated_records,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE value IS NULL
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS missing_percentage
FROM analytics.loan_clean c
CROSS JOIN LATERAL
    JSONB_EACH(TO_JSONB(c)) AS fields(column_name, value)
GROUP BY column_name
ORDER BY missing_records DESC, column_name;


-- =========================================================
-- 6. DATE CHRONOLOGY VALIDATION
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE earliest_cr_line > issue_d
    ) AS credit_dates_after_issue_dates,
    COUNT(*) FILTER (
        WHERE last_pymnt_d < issue_d
    ) AS last_payment_before_issue,
    COUNT(*) FILTER (
        WHERE next_pymnt_d < issue_d
    ) AS next_payment_before_issue
FROM analytics.loan_clean;


-- =========================================================
-- 7. EARLIEST CREDIT LINE DATE PROFILE
-- =========================================================

SELECT
    MIN(earliest_cr_line) AS earliest_credit_date,
    MAX(earliest_cr_line) AS latest_credit_date,
    COUNT(*) AS total_records,
    COUNT(earliest_cr_line) AS populated_dates
FROM analytics.loan_clean;


-- =========================================================
-- 8. LOAN FUNDING CONSISTENCY
-- =========================================================

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE funded_amnt > loan_amnt
    ) AS funded_above_requested,

    COUNT(*) FILTER (
        WHERE funded_amnt_inv > funded_amnt
    ) AS investor_funding_above_total,

    COUNT(*) FILTER (
        WHERE funded_amnt_inv = 0
    ) AS zero_investor_funding,

    COUNT(*) FILTER (
        WHERE loan_amnt = funded_amnt
    ) AS requested_equals_funded,

    COUNT(*) FILTER (
        WHERE funded_amnt = funded_amnt_inv
    ) AS funded_equals_investor
FROM analytics.loan_clean;


-- =========================================================
-- 9. INVESTOR PAYMENT DIFFERENCES
-- =========================================================

SELECT
    COUNT(*) FILTER (
        WHERE total_pymnt_inv > total_pymnt
    ) AS investor_payment_above_total,

    MAX(
        total_pymnt_inv - total_pymnt
    ) FILTER (
        WHERE total_pymnt_inv > total_pymnt
    ) AS maximum_excess,

    MIN(
        total_pymnt_inv - total_pymnt
    ) FILTER (
        WHERE total_pymnt_inv > total_pymnt
    ) AS minimum_excess,

    AVG(
        total_pymnt_inv - total_pymnt
    ) FILTER (
        WHERE total_pymnt_inv > total_pymnt
    ) AS average_excess
FROM analytics.loan_clean;


-- =========================================================
-- 10. PRINCIPAL RECEIVED VS ORIGINAL LOAN AMOUNT
-- =========================================================

SELECT
    COUNT(*) FILTER (
        WHERE total_rec_prncp > loan_amnt
    ) AS principal_above_original_loan,

    MAX(
        total_rec_prncp - loan_amnt
    ) FILTER (
        WHERE total_rec_prncp > loan_amnt
    ) AS maximum_excess
FROM analytics.loan_clean;


-- =========================================================
-- 11. PAYMENT FIELD COMPLETENESS
-- =========================================================

SELECT
    COUNT(*) AS total_records,

    COUNT(total_pymnt) AS populated_total_payments,
    COUNT(total_rec_prncp) AS populated_principal_received,
    COUNT(total_rec_int) AS populated_interest_received,
    COUNT(total_rec_late_fee) AS populated_late_fees,
    COUNT(recoveries) AS populated_recoveries,
    COUNT(collection_recovery_fee) AS populated_recovery_fees
FROM analytics.loan_clean;


-- =========================================================
-- 12. RECOVERIES BY LOAN STATUS
-- =========================================================

SELECT
    loan_status,
    COUNT(*) AS loan_count,

    COUNT(*) FILTER (
        WHERE recoveries > 0
    ) AS loans_with_recoveries,

    SUM(recoveries) AS total_recoveries,

    SUM(collection_recovery_fee) AS total_recovery_fees
FROM analytics.loan_clean
GROUP BY loan_status
ORDER BY loan_status;


-- =========================================================
-- 13. DATE FIELD COMPLETENESS
-- =========================================================

SELECT
    COUNT(*) AS total_records,

    COUNT(issue_d) AS populated_issue_dates,
    COUNT(last_pymnt_d) AS populated_last_payment_dates,
    COUNT(next_pymnt_d) AS populated_next_payment_dates,
    COUNT(last_credit_pull_d) AS populated_credit_pull_dates
FROM analytics.loan_clean;


-- =========================================================
-- 14. CURRENT LOAN NEXT PAYMENT DATE CHECK
-- =========================================================

SELECT
    loan_status,
    COUNT(*) AS total_loans,

    COUNT(next_pymnt_d) AS populated_next_payment_dates,

    COUNT(*) FILTER (
        WHERE next_pymnt_d IS NULL
    ) AS missing_next_payment_dates
FROM analytics.loan_clean
GROUP BY loan_status
ORDER BY loan_status;


/*
============================================================
VALIDATION BASELINE

Previously established results:

- Raw records: 39,717
- Clean records: 39,717
- Matching IDs: 39,717
- Raw IDs missing from clean: 0
- Clean IDs missing from raw: 0
- Distinct clean IDs: 39,717
- Duplicate or missing clean IDs: 0
- Clean table columns: 42
- Earliest credit date: 1946-01-01
- Latest credit date: 2008-11-01
- Century corrections: 127
- Remaining credit-date chronology violations: 0
- Funded amount above requested amount: 0
- Investor funding above total funding: 0

Known small differences:
- Investor payment differences were no greater than
  approximately half a cent.
- Principal received exceeded original loan amount in
  108 records, with a maximum excess of $0.25.

These small differences were retained rather than
altered or deleted.
============================================================
*/
