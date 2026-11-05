-- ============================================================
-- 06_LOAN_PERFORMANCE_ANALYSIS.SQL
-- Database: loan_portfolio_db
-- Source: analytics.loan_clean
--
-- Purpose:
-- Analyse historical loan outcomes, payment collections,
-- charge-offs, recoveries and recorded outstanding principal.
--
-- Dataset origination period: 2007–2011
-- Historical payment records extend to 2016.
-- ============================================================


-- ============================================================
-- 1. OVERALL LOAN PERFORMANCE BY STATUS
-- ============================================================

SELECT
    loan_status,
    COUNT(*) AS total_loans,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(total_pymnt) AS total_payments_received,
    SUM(total_rec_prncp) AS principal_received,
    SUM(total_rec_int) AS interest_received,
    SUM(recoveries) AS recoveries,
    SUM(out_prncp) AS recorded_outstanding_principal
FROM analytics.loan_clean
GROUP BY loan_status
ORDER BY
    CASE loan_status
        WHEN 'Fully Paid' THEN 1
        WHEN 'Charged Off' THEN 2
        WHEN 'Current' THEN 3
        ELSE 4
    END;


-- ============================================================
-- 2. CHARGE-OFF RATE BY ORIGINATION YEAR
-- Excludes Current loans from the resolved-loan denominator.
-- ============================================================

SELECT
    EXTRACT(YEAR FROM issue_d)::INTEGER AS origination_year,
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
GROUP BY EXTRACT(YEAR FROM issue_d)
ORDER BY origination_year;


-- ============================================================
-- 3. CHARGE-OFF RATE BY LOAN TERM
-- ============================================================

SELECT
    term,
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
GROUP BY term
ORDER BY term;


-- ============================================================
-- 4. RECOVERY PERFORMANCE ON CHARGED-OFF LOANS
-- ============================================================

SELECT
    COUNT(*) AS charged_off_loans,

    COUNT(*) FILTER (
        WHERE recoveries > 0
    ) AS loans_with_recoveries,

    ROUND(
        COUNT(*) FILTER (
            WHERE recoveries > 0
        ) * 100.0 / COUNT(*),
        2
    ) AS recovery_incidence_rate,

    SUM(recoveries) AS total_recoveries,

    ROUND(AVG(recoveries), 2) AS average_recovery_per_loan,

    MAX(recoveries) AS highest_recovery,

    SUM(collection_recovery_fee) AS total_recovery_fees

FROM analytics.loan_clean
WHERE loan_status = 'Charged Off';


-- ============================================================
-- 5. PRINCIPAL, INTEREST AND FEES RECEIVED BY LOAN STATUS
-- ============================================================

SELECT
    loan_status,
    COUNT(*) AS total_loans,
    SUM(funded_amnt) AS total_funded_amount,
    SUM(total_rec_prncp) AS principal_received,
    SUM(total_rec_int) AS interest_received,
    SUM(total_rec_late_fee) AS late_fees_received,
    SUM(recoveries) AS recoveries,
    SUM(total_pymnt) AS total_payments_received
FROM analytics.loan_clean
GROUP BY loan_status
ORDER BY
    CASE loan_status
        WHEN 'Fully Paid' THEN 1
        WHEN 'Charged Off' THEN 2
        WHEN 'Current' THEN 3
        ELSE 4
    END;


-- ============================================================
-- 6. RECORDED OUTSTANDING PRINCIPAL BY LOAN STATUS
-- Historical snapshot values; not present-day balances.
-- ============================================================

SELECT
    loan_status,
    COUNT(*) AS total_loans,
    SUM(out_prncp) AS total_outstanding_principal,
    ROUND(AVG(out_prncp), 2) AS average_outstanding_principal,
    MAX(out_prncp) AS highest_outstanding_principal,
    SUM(out_prncp_inv) AS investor_outstanding_principal
FROM analytics.loan_clean
GROUP BY loan_status
ORDER BY
    CASE loan_status
        WHEN 'Fully Paid' THEN 1
        WHEN 'Charged Off' THEN 2
        WHEN 'Current' THEN 3
        ELSE 4
    END;