
-- =========================================================
-- PROJECT: LOAN PORTFOLIO AND CREDIT RISK ANALYSIS
-- SCRIPT: 09_grade_and_pricing_risk_analysis.sql
-- PURPOSE:
-- Analyse charge-off risk, interest-rate pricing, and
-- funding exposure across credit grades and sub-grades.
--
-- NOTE:
-- Charge-off rates use resolved loans only:
-- Charged Off / (Fully Paid + Charged Off).
-- Current loans are excluded from the denominator.
-- =========================================================


-- =========================================================
-- 1. CHARGE-OFF RATE BY LOAN GRADE
-- =========================================================

SELECT
    grade,
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
        100.0 * COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS charge_off_rate
FROM analytics.loan_clean
GROUP BY grade
ORDER BY grade;


-- =========================================================
-- 2. CHARGE-OFF RATE BY LOAN SUB-GRADE
-- =========================================================

SELECT
    grade,
    sub_grade,
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
        100.0 * COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS charge_off_rate
FROM analytics.loan_clean
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;


-- =========================================================
-- 3. INTEREST RATE AND CHARGE-OFF RATE BY SUB-GRADE
-- =========================================================

SELECT
    grade,
    sub_grade,
    COUNT(*) AS total_loans,
    COUNT(int_rate) AS loans_with_interest_rate,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    ROUND(
        AVG(int_rate) FILTER (
            WHERE loan_status IN ('Fully Paid', 'Charged Off')
        ),
        2
    ) AS average_interest_rate_resolved,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS charge_off_rate
FROM analytics.loan_clean
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;


-- =========================================================
-- 4. LOAN VOLUMES AND FUNDING BY CREDIT GRADE
-- =========================================================

SELECT
    grade,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_requested_amount,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(funded_amnt_inv) AS total_investor_funded_amount,
    ROUND(AVG(loan_amnt), 2) AS average_requested_loan,
    ROUND(AVG(funded_amnt), 2) AS average_funded_loan,
    ROUND(AVG(int_rate), 2) AS average_interest_rate,
    COUNT(*) FILTER (
        WHERE loan_status = 'Charged Off'
    ) AS charged_off_loans,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE loan_status = 'Charged Off'
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE loan_status IN ('Fully Paid', 'Charged Off')
            ),
            0
        ),
        2
    ) AS charge_off_rate
FROM analytics.loan_clean
GROUP BY grade
ORDER BY grade;


