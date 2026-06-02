# Layoffs vs AI Hiring: Are Companies Cutting People or Replacing Them?

**Tools:** R · SQL · Power BI · Kaggle datasets

## Overview

Between 2022 and 2024, the tech industry saw over 400,000 layoffs — while simultaneously posting record numbers of AI and ML job openings. This project investigates whether AI adoption is driving workforce reduction, creating new roles, or both — and which industries are most exposed.

## Key Questions

- Do companies with high AI investment correlate with higher layoff rates?
- Which job categories are shrinking vs. growing as AI scales?
- Is there a lag between layoffs and AI hiring that signals replacement vs. retraining?

## Data Sources

- [Kaggle: Tech Layoffs 2022–2024](https://www.kaggle.com/datasets/swaptr/layoffs-2022) — company, headcount, industry, date
- [Kaggle: AI/ML Job Postings](https://www.kaggle.com/datasets/ravindrasinghrana/job-description-dataset) — role titles, required skills, company size
- Bureau of Labor Statistics (BLS) JOLTS data — sector-level hiring and separation rates

## Methodology

```
Raw CSVs (Kaggle + BLS)
    │
    ▼
SQL (data cleaning, joins, aggregation by industry/quarter)
    │
    ▼
R (correlation analysis, trend modeling, ggplot2 visualizations)
    │
    ▼
Power BI (interactive dashboard — filter by industry, company size, time period)
```

## Findings Summary

- **Layoffs and AI hiring peaked simultaneously in Q1 2023**, concentrated in software and finance
- Companies that announced AI investments in earnings calls were **2.3x more likely** to also announce layoffs within the same quarter
- AI/ML roles are growing, but at ~30% of the volume of eliminated roles — net job loss in most sectors
- **Healthcare and manufacturing** show the opposite pattern: AI investment correlated with workforce expansion

## Files

| File | Description |
|---|---|
| `data/layoffs_cleaned.csv` | Cleaned layoff dataset (company, date, headcount, industry) |
| `data/ai_jobs_cleaned.csv` | AI/ML job postings aggregated by quarter and sector |
| `sql/clean_and_join.sql` | SQL used for data prep and cross-dataset joins |
| `r/analysis.R` | R script: correlation analysis + ggplot2 charts |
| `r/charts/` | Exported chart PNGs |
| `powerbi/layoffs_vs_hiring.pbix` | Power BI dashboard file |
| `powerbi/dashboard_screenshot.png` | Dashboard preview |

## Dashboard Preview

![Dashboard](powerbi/dashboard_screenshot.png)

---

*Analysis by Neha Sinha · [GitHub](https://github.com/nehasinha1)*
