# 05 — Portfolio Overview
-- Database: loan_portfolio_db
-- Source table: analytics.loan_clean
-- Purpose: Examine the size, composition, funding and origination
-- patterns of the historical LendingClub loan portfolio (2007–2011).

-- ============================================================
-- 1. OVERALL PORTFOLIO SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_loans,
    COUNT(DISTINCT id) AS unique_loans,
    SUM(loan_amnt) AS total_loan_amount,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(funded_amnt_inv) AS total_investor_funded,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY loan_amnt)::NUMERIC,
        2
    ) AS median_loan_amount,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    ROUND(AVG(dti), 2) AS average_dti
FROM analytics.loan_clean;


-- ============================================================
-- 2. LOAN STATUS DISTRIBUTION
-- ============================================================

SELECT
    loan_status,
    COUNT(*) AS total_loans,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_portfolio,
    SUM(loan_amnt) AS total_loan_amount,
    SUM(funded_amnt) AS total_funded_amount
FROM analytics.loan_clean
GROUP BY loan_status
ORDER BY total_loans DESC;


-- ============================================================
-- 3. ORIGINATION TRENDS
-- ============================================================

SELECT
    EXTRACT(YEAR FROM issue_d)::INTEGER AS origination_year,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_loan_amount,
    SUM(funded_amnt) AS total_funded_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount
FROM analytics.loan_clean
GROUP BY EXTRACT(YEAR FROM issue_d)
ORDER BY origination_year;


-- ============================================================
-- 4. LOAN TERM DISTRIBUTION
-- ============================================================

SELECT
    term,
    COUNT(*) AS total_loans,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_portfolio,
    SUM(loan_amnt) AS total_loan_amount,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount
FROM analytics.loan_clean
GROUP BY term
ORDER BY term;


-- ============================================================
-- 5. LOAN TERM BY ORIGINATION YEAR
-- ============================================================

SELECT
    EXTRACT(YEAR FROM issue_d)::INTEGER AS origination_year,
    term,
    COUNT(*) AS total_loans,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY EXTRACT(YEAR FROM issue_d)
        ),
        2
    ) AS percentage_within_year
FROM analytics.loan_clean
GROUP BY
    EXTRACT(YEAR FROM issue_d),
    term
ORDER BY
    origination_year,
    term;


-- ============================================================
-- 6. AVERAGE INTEREST RATE BY LOAN GRADE
-- ============================================================

SELECT
    grade,
    COUNT(*) AS total_loans,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    MIN(int_rate) AS minimum_interest_rate,
    MAX(int_rate) AS maximum_interest_rate
FROM analytics.loan_clean
GROUP BY grade
ORDER BY grade;


-- ============================================================
-- 7. CONSOLIDATED ORIGINATION-YEAR SUMMARY
-- ============================================================

SELECT
    EXTRACT(YEAR FROM issue_d)::INTEGER AS origination_year,
    COUNT(*) AS total_loans,
    SUM(funded_amnt) AS total_funded_amount,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    ROUND(AVG(loan_amnt), 2) AS average_loan_amount
FROM analytics.loan_clean
GROUP BY EXTRACT(YEAR FROM issue_d)
ORDER BY origination_year;