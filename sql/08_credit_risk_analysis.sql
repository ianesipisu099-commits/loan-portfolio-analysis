# 08 — Credit Risk Analysis

-- Project: Lending Club Loan Portfolio & Credit Risk Analysis
-- Database: loan_portfolio_db
-- Schema: analytics
-- Table: loan_clean
--
-- Objective:
-- Examine how borrowers' credit-history characteristics relate
-- to historical loan repayment outcomes.
--
-- Method:
-- Charge-off rate = Charged Off loans /
--                   (Fully Paid + Charged Off loans) * 100
--
-- Current loans are excluded from the charge-off rate denominator
-- because their final outcomes are not recorded in this snapshot.
--
-- Missing values are excluded from analyses where applicable.

-- ============================================================
-- SECTION 1: CHARGE-OFF RATE BY PREVIOUS DELINQUENCIES
-- ============================================================

SELECT
    CASE
        WHEN delinq_2yrs = 0 THEN '01. No previous delinquencies'
        WHEN delinq_2yrs = 1 THEN '02. One previous delinquency'
        WHEN delinq_2yrs = 2 THEN '03. Two previous delinquencies'
        ELSE '04. Three or more previous delinquencies'
    END AS delinquency_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Fully Paid'
    ) AS fully_paid_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Current'
    ) AS current_loans,
    ROUND(
        COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS resolved_loan_charge_off_rate
FROM analytics.loan_clean
WHERE delinq_2yrs IS NOT NULL
GROUP BY delinquency_band
ORDER BY delinquency_band;


-- ============================================================
-- SECTION 2: CHARGE-OFF RATE BY RECENT CREDIT INQUIRIES
-- ============================================================

SELECT
    CASE
        WHEN inq_last_6mths = 0 THEN '01. No recent inquiries'
        WHEN inq_last_6mths = 1 THEN '02. One recent inquiry'
        WHEN inq_last_6mths = 2 THEN '03. Two recent inquiries'
        WHEN inq_last_6mths = 3 THEN '04. Three recent inquiries'
        ELSE '05. Four or more recent inquiries'
    END AS inquiry_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Fully Paid'
    ) AS fully_paid_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Current'
    ) AS current_loans,
    ROUND(
        COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS resolved_loan_charge_off_rate
FROM analytics.loan_clean
WHERE inq_last_6mths IS NOT NULL
GROUP BY inquiry_band
ORDER BY inquiry_band;


-- ============================================================
-- SECTION 3: CHARGE-OFF RATE BY REVOLVING CREDIT UTILISATION
-- ============================================================

SELECT
    CASE
        WHEN revol_util <= 20 THEN '01. 0%–20%'
        WHEN revol_util <= 40 THEN '02. 20.01%–40%'
        WHEN revol_util <= 60 THEN '03. 40.01%–60%'
        WHEN revol_util <= 80 THEN '04. 60.01%–80%'
        ELSE '05. Above 80%'
    END AS utilisation_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Fully Paid'
    ) AS fully_paid_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Current'
    ) AS current_loans,
    ROUND(
        COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS resolved_loan_charge_off_rate
FROM analytics.loan_clean
WHERE revol_util IS NOT NULL
GROUP BY utilisation_band
ORDER BY utilisation_band;


-- ============================================================
-- SECTION 4: CHARGE-OFF RATE BY PUBLIC DEROGATORY RECORDS
-- ============================================================

SELECT
    CASE
        WHEN pub_rec = 0 THEN '01. No public derogatory records'
        WHEN pub_rec = 1 THEN '02. One public derogatory record'
        ELSE '03. Two or more public derogatory records'
    END AS public_record_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Fully Paid'
    ) AS fully_paid_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Current'
    ) AS current_loans,
    ROUND(
        COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS resolved_loan_charge_off_rate
FROM analytics.loan_clean
WHERE pub_rec IS NOT NULL
GROUP BY public_record_band
ORDER BY public_record_band;


-- ============================================================
-- SECTION 5: CHARGE-OFF RATE BY PREVIOUS BANKRUPTCIES
-- ============================================================

SELECT
    CASE
        WHEN pub_rec_bankruptcies = 0 THEN '01. No recorded bankruptcies'
        WHEN pub_rec_bankruptcies = 1 THEN '02. One recorded bankruptcy'
        ELSE '03. Two or more recorded bankruptcies'
    END AS bankruptcy_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Fully Paid'
    ) AS fully_paid_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Current'
    ) AS current_loans,
    ROUND(
        COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS resolved_loan_charge_off_rate
FROM analytics.loan_clean
WHERE pub_rec_bankruptcies IS NOT NULL
GROUP BY bankruptcy_band
ORDER BY bankruptcy_band;


-- ============================================================
-- SECTION 6: CHARGE-OFF RATE BY NUMBER OF OPEN CREDIT ACCOUNTS
-- ============================================================

SELECT
    CASE
        WHEN open_acc <= 2 THEN '01. 0–2 open accounts'
        WHEN open_acc <= 5 THEN '02. 3–5 open accounts'
        WHEN open_acc <= 10 THEN '03. 6–10 open accounts'
        WHEN open_acc <= 15 THEN '04. 11–15 open accounts'
        ELSE '05. More than 15 open accounts'
    END AS open_account_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Fully Paid'
    ) AS fully_paid_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Current'
    ) AS current_loans,
    ROUND(
        COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS resolved_loan_charge_off_rate
FROM analytics.loan_clean
WHERE open_acc IS NOT NULL
GROUP BY open_account_band
ORDER BY open_account_band;


-- ============================================================
-- SECTION 7: CHARGE-OFF RATE BY CREDIT-HISTORY AGE
-- ============================================================

SELECT
    CASE
        WHEN (issue_d - earliest_cr_line) / 365.25 < 5
            THEN '01. 2–5 years'
        WHEN (issue_d - earliest_cr_line) / 365.25 < 10
            THEN '02. 5–10 years'
        WHEN (issue_d - earliest_cr_line) / 365.25 < 15
            THEN '03. 10–15 years'
        ELSE '04. More than 15 years'
    END AS credit_history_band,
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Fully Paid'
    ) AS fully_paid_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    COUNT(*) FILTER (
        WHERE loan_status = 'Current'
    ) AS current_loans,
    ROUND(
        COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS resolved_loan_charge_off_rate
FROM analytics.loan_clean
WHERE earliest_cr_line IS NOT NULL
  AND issue_d IS NOT NULL
GROUP BY credit_history_band
ORDER BY credit_history_band;


-- ============================================================
-- END OF CREDIT RISK ANALYSIS
-- ============================================================