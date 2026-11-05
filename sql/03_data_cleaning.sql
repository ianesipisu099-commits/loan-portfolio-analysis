/*
============================================================
PROJECT: Lending Club Loan Portfolio & Credit Risk Analysis
FILE: 03_data_cleaning.sql

PURPOSE:
1. Create the analytics.loan_clean table.
2. Convert source text fields into appropriate data types.
3. Standardise missing values.
4. Clean percentage and categorical fields.
5. Correct two-digit-year date parsing issues.

SOURCE TABLE:
- staging.loan_raw

OUTPUT TABLE:
- analytics.loan_clean

SOURCE DATA:
- 39,717 records
- 111 columns

CLEAN TABLE:
- 42 selected columns

IMPORTANT:
- staging.loan_raw remains unchanged.
- No records are intentionally deleted.
- No outliers are capped or removed.
- Percentage values remain in percentage points.
============================================================
*/


-- =========================================================
-- 1. CREATE ANALYTICS SCHEMA
-- =========================================================

CREATE SCHEMA IF NOT EXISTS analytics;


-- =========================================================
-- 2. CREATE CLEAN TABLE
-- =========================================================

-- Only execute the DROP statement when intentionally
-- rebuilding the existing clean table.

DROP TABLE IF EXISTS analytics.loan_clean;


CREATE TABLE analytics.loan_clean AS

WITH parsed_dates AS (

    SELECT
        *,
        TO_DATE(
            '01-' || BTRIM(issue_d),
            'DD-Mon-YY'
        ) AS issue_date_parsed,

        TO_DATE(
            '01-' || BTRIM(earliest_cr_line),
            'DD-Mon-YY'
        ) AS credit_date_parsed,

        TO_DATE(
            '01-' || BTRIM(last_pymnt_d),
            'DD-Mon-YY'
        ) AS last_payment_date_parsed,

        TO_DATE(
            '01-' || BTRIM(next_pymnt_d),
            'DD-Mon-YY'
        ) AS next_payment_date_parsed,

        TO_DATE(
            '01-' || BTRIM(last_credit_pull_d),
            'DD-Mon-YY'
        ) AS credit_pull_date_parsed

    FROM staging.loan_raw

)

SELECT

    -- =====================================================
    -- A. LOAN IDENTIFICATION AND CHARACTERISTICS
    -- =====================================================

    NULLIF(BTRIM(id), '') AS id,

    NULLIF(BTRIM(loan_amnt), 'NA')::NUMERIC
        AS loan_amnt,

    NULLIF(BTRIM(funded_amnt), 'NA')::NUMERIC
        AS funded_amnt,

    NULLIF(BTRIM(funded_amnt_inv), 'NA')::NUMERIC
        AS funded_amnt_inv,

    NULLIF(BTRIM(term), '') AS term,

    NULLIF(
        REPLACE(BTRIM(int_rate), '%', ''),
        'NA'
    )::NUMERIC AS int_rate,

    NULLIF(BTRIM(installment), 'NA')::NUMERIC
        AS installment,

    NULLIF(BTRIM(grade), '') AS grade,

    NULLIF(BTRIM(sub_grade), '') AS sub_grade,

    NULLIF(BTRIM(purpose), '') AS purpose,


    -- =====================================================
    -- B. BORROWER PROFILE
    -- =====================================================

    CASE
        WHEN LOWER(BTRIM(emp_length)) IN ('n/a', 'na', '')
            THEN NULL
        ELSE BTRIM(emp_length)
    END AS emp_length,

    NULLIF(BTRIM(home_ownership), '') AS home_ownership,

    NULLIF(BTRIM(annual_inc), 'NA')::NUMERIC
        AS annual_inc,

    NULLIF(BTRIM(verification_status), '')
        AS verification_status,

    NULLIF(BTRIM(addr_state), '') AS addr_state,

    NULLIF(BTRIM(dti), 'NA')::NUMERIC AS dti,


    -- =====================================================
    -- C. CREDIT HISTORY
    -- =====================================================

    NULLIF(BTRIM(delinq_2yrs), 'NA')::INTEGER
        AS delinq_2yrs,

    CASE
        WHEN credit_date_parsed > issue_date_parsed
            THEN (credit_date_parsed - INTERVAL '100 years')::DATE
        ELSE credit_date_parsed
    END AS earliest_cr_line,

    NULLIF(BTRIM(inq_last_6mths), 'NA')::INTEGER
        AS inq_last_6mths,

    NULLIF(BTRIM(mths_since_last_delinq), 'NA')::INTEGER
        AS mths_since_last_delinq,

    NULLIF(BTRIM(mths_since_last_record), 'NA')::INTEGER
        AS mths_since_last_record,

    NULLIF(BTRIM(open_acc), 'NA')::INTEGER
        AS open_acc,

    NULLIF(BTRIM(pub_rec), 'NA')::INTEGER
        AS pub_rec,

    NULLIF(BTRIM(revol_bal), 'NA')::NUMERIC
        AS revol_bal,

    NULLIF(
        REPLACE(BTRIM(revol_util), '%', ''),
        'NA'
    )::NUMERIC AS revol_util,

    NULLIF(BTRIM(total_acc), 'NA')::INTEGER
        AS total_acc,

    NULLIF(BTRIM(pub_rec_bankruptcies), 'NA')::INTEGER
        AS pub_rec_bankruptcies,


    -- =====================================================
    -- D. LOAN PERFORMANCE
    -- =====================================================

    NULLIF(BTRIM(loan_status), '') AS loan_status,

    NULLIF(BTRIM(out_prncp), 'NA')::NUMERIC
        AS out_prncp,

    NULLIF(BTRIM(out_prncp_inv), 'NA')::NUMERIC
        AS out_prncp_inv,

    NULLIF(BTRIM(total_pymnt), 'NA')::NUMERIC
        AS total_pymnt,

    NULLIF(BTRIM(total_pymnt_inv), 'NA')::NUMERIC
        AS total_pymnt_inv,

    NULLIF(BTRIM(total_rec_prncp), 'NA')::NUMERIC
        AS total_rec_prncp,

    NULLIF(BTRIM(total_rec_int), 'NA')::NUMERIC
        AS total_rec_int,

    NULLIF(BTRIM(total_rec_late_fee), 'NA')::NUMERIC
        AS total_rec_late_fee,

    NULLIF(BTRIM(recoveries), 'NA')::NUMERIC
        AS recoveries,

    NULLIF(BTRIM(collection_recovery_fee), 'NA')::NUMERIC
        AS collection_recovery_fee,

    NULLIF(BTRIM(last_pymnt_amnt), 'NA')::NUMERIC
        AS last_pymnt_amnt,


    -- =====================================================
    -- E. DATE FIELDS
    -- =====================================================

    issue_date_parsed AS issue_d,

    last_payment_date_parsed AS last_pymnt_d,

    next_payment_date_parsed AS next_pymnt_d,

    credit_pull_date_parsed AS last_credit_pull_d

FROM parsed_dates;