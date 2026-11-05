# 07 — Borrower Risk Analysis

-- Project: Lending Club Loan Portfolio & Credit Risk Analysis
-- Database: loan_portfolio_db
-- Schema: analytics
-- Table: loan_clean
--
-- Objective:
-- Examine how borrower characteristics relate to historical loan outcomes.
--
-- Method:
-- Charge-off rate = Charged Off loans / (Fully Paid + Charged Off loans) * 100
--
-- Current loans are excluded from the charge-off rate denominator because
-- their final outcomes are not yet recorded in this historical snapshot.

-- ============================================================
-- SECTION 1: CHARGE-OFF RATE BY DEBT-TO-INCOME (DTI) RATIO
-- ============================================================

SELECT
    CASE
        WHEN dti <= 5 THEN '01. 0%–5%'
        WHEN dti <= 10 THEN '02. 5.01%–10%'
        WHEN dti <= 15 THEN '03. 10.01%–15%'
        WHEN dti <= 20 THEN '04. 15.01%–20%'
        WHEN dti <= 25 THEN '05. 20.01%–25%'
        ELSE '06. Above 25%'
    END AS dti_band,
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
GROUP BY dti_band
ORDER BY dti_band;


-- ============================================================
-- SECTION 2: CHARGE-OFF RATE BY ANNUAL INCOME
-- ============================================================

SELECT
    CASE
        WHEN annual_inc <= 25000 THEN '01. Up to $25,000'
        WHEN annual_inc <= 50000 THEN '02. $25,001–$50,000'
        WHEN annual_inc <= 75000 THEN '03. $50,001–$75,000'
        WHEN annual_inc <= 100000 THEN '04. $75,001–$100,000'
        WHEN annual_inc <= 150000 THEN '05. $100,001–$150,000'
        WHEN annual_inc <= 250000 THEN '06. $150,001–$250,000'
        ELSE '07. Above $250,000'
    END AS income_band,
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
GROUP BY income_band
ORDER BY income_band;


-- ============================================================
-- SECTION 3: CHARGE-OFF RATE BY EMPLOYMENT LENGTH
-- ============================================================

SELECT
    COALESCE(emp_length, 'Not reported') AS employment_length,
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
GROUP BY emp_length
ORDER BY
    CASE COALESCE(emp_length, 'Not reported')
        WHEN '< 1 year' THEN 1
        WHEN '1 year' THEN 2
        WHEN '2 years' THEN 3
        WHEN '3 years' THEN 4
        WHEN '4 years' THEN 5
        WHEN '5 years' THEN 6
        WHEN '6 years' THEN 7
        WHEN '7 years' THEN 8
        WHEN '8 years' THEN 9
        WHEN '9 years' THEN 10
        WHEN '10+ years' THEN 11
        ELSE 12
    END;


-- ============================================================
-- SECTION 4: CHARGE-OFF RATE BY HOME OWNERSHIP
-- ============================================================

SELECT
    home_ownership,
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
GROUP BY home_ownership
ORDER BY total_loans DESC;


-- ============================================================
-- SECTION 5: CHARGE-OFF RATE BY LOAN PURPOSE
-- ============================================================

SELECT
    purpose,
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
GROUP BY purpose
ORDER BY resolved_loan_charge_off_rate DESC;


-- ============================================================
-- END OF BORROWER RISK ANALYSIS
-- ============================================================