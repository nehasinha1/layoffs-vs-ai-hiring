-- ============================================================
-- Layoffs vs AI Hiring: Data Cleaning & Join
-- ============================================================

-- 1. Clean layoffs table
CREATE TABLE layoffs_clean AS
SELECT
    company,
    industry,
    country,
    DATE_TRUNC('quarter', laid_off_date) AS quarter,
    SUM(total_laid_off)                  AS total_laid_off,
    AVG(percentage_laid_off)             AS avg_pct_laid_off,
    MAX(funds_raised_millions)           AS funds_raised_m
FROM raw_layoffs
WHERE
    total_laid_off IS NOT NULL
    AND laid_off_date BETWEEN '2022-01-01' AND '2024-12-31'
GROUP BY 1, 2, 3, 4;

-- 2. Clean AI job postings table
CREATE TABLE ai_jobs_clean AS
SELECT
    company,
    industry,
    DATE_TRUNC('quarter', posting_date) AS quarter,
    COUNT(*)                            AS ai_job_postings,
    COUNT(DISTINCT role_category)       AS distinct_role_types
FROM raw_job_postings
WHERE
    LOWER(title) SIMILAR TO '%(machine learning|artificial intelligence|ai engineer|data scientist|llm|nlp|ml ops)%'
    AND posting_date BETWEEN '2022-01-01' AND '2024-12-31'
GROUP BY 1, 2, 3;

-- 3. Join layoffs and AI hiring by industry + quarter
CREATE TABLE industry_quarterly AS
SELECT
    COALESCE(l.industry, j.industry) AS industry,
    COALESCE(l.quarter, j.quarter)   AS quarter,
    COALESCE(l.total_laid_off, 0)    AS total_laid_off,
    COALESCE(j.ai_job_postings, 0)   AS ai_job_postings,
    ROUND(
        COALESCE(j.ai_job_postings, 0)::NUMERIC /
        NULLIF(COALESCE(l.total_laid_off, 0) + COALESCE(j.ai_job_postings, 0), 0) * 100,
        2
    )                                AS ai_hire_share_pct
FROM layoffs_clean l
FULL OUTER JOIN ai_jobs_clean j
    ON l.industry = j.industry AND l.quarter = j.quarter
ORDER BY quarter, industry;

-- 4. Summary: net headcount delta per industry (2022–2024)
SELECT
    industry,
    SUM(total_laid_off)   AS total_cut,
    SUM(ai_job_postings)  AS total_ai_hired,
    SUM(ai_job_postings) - SUM(total_laid_off) AS net_headcount_delta
FROM industry_quarterly
GROUP BY industry
ORDER BY net_headcount_delta ASC;
