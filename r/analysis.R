library(tidyverse)
library(ggplot2)
library(scales)
library(corrplot)

# ── Load cleaned data ──────────────────────────────────────────────────────────
layoffs <- read_csv("../data/layoffs_cleaned.csv")
ai_jobs <- read_csv("../data/ai_jobs_cleaned.csv")

quarterly <- read_csv("../data/industry_quarterly.csv") |>
  mutate(quarter = as.Date(quarter))

# ── 1. Trend: Layoffs vs AI Hiring over time ───────────────────────────────────
quarterly_totals <- quarterly |>
  group_by(quarter) |>
  summarise(
    laid_off   = sum(total_laid_off),
    ai_hired   = sum(ai_job_postings)
  ) |>
  pivot_longer(c(laid_off, ai_hired), names_to = "metric", values_to = "count")

ggplot(quarterly_totals, aes(x = quarter, y = count, color = metric)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_y_continuous(labels = comma) +
  scale_color_manual(
    values = c(laid_off = "#E84545", ai_hired = "#2B7A78"),
    labels = c(laid_off = "Layoffs", ai_hired = "AI Job Postings")
  ) +
  labs(
    title    = "Layoffs vs AI Hiring (2022–2024)",
    subtitle = "Quarterly totals across all tracked industries",
    x        = NULL, y = "Headcount", color = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "top")

ggsave("charts/layoffs_vs_ai_hiring_trend.png", width = 10, height = 5, dpi = 150)

# ── 2. Industry comparison: net headcount delta ────────────────────────────────
net_delta <- quarterly |>
  group_by(industry) |>
  summarise(
    total_cut    = sum(total_laid_off),
    total_hired  = sum(ai_job_postings),
    net_delta    = total_hired - total_cut
  ) |>
  arrange(net_delta) |>
  mutate(industry = fct_inorder(industry), direction = if_else(net_delta >= 0, "gain", "loss"))

ggplot(net_delta, aes(x = net_delta, y = industry, fill = direction)) +
  geom_col() +
  scale_fill_manual(values = c(gain = "#2B7A78", loss = "#E84545"), guide = "none") +
  scale_x_continuous(labels = comma) +
  labs(
    title    = "Net Headcount Delta by Industry (AI Hired − Laid Off)",
    subtitle = "2022–2024 cumulative",
    x        = "Net Change", y = NULL
  ) +
  theme_minimal(base_size = 13)

ggsave("charts/net_headcount_by_industry.png", width = 9, height = 6, dpi = 150)

# ── 3. Correlation: AI investment mentions vs layoff rate ──────────────────────
# (Assumes a company-level dataset with ai_mention_flag and pct_laid_off columns)
company_level <- layoffs |>
  inner_join(ai_jobs, by = c("company", "quarter")) |>
  group_by(company, industry) |>
  summarise(
    avg_pct_laid_off  = mean(avg_pct_laid_off, na.rm = TRUE),
    total_ai_postings = sum(ai_job_postings)
  )

cor_val <- cor(company_level$total_ai_postings, company_level$avg_pct_laid_off,
               use = "complete.obs")
cat(sprintf("Correlation (AI postings vs layoff %%): %.3f\n", cor_val))

ggplot(company_level, aes(x = total_ai_postings, y = avg_pct_laid_off, color = industry)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 0.8) +
  scale_x_log10(labels = comma) +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  labs(
    title    = "AI Hiring Activity vs Layoff Rate by Company",
    subtitle = sprintf("Pearson r = %.2f", cor_val),
    x        = "AI Job Postings (log scale)", y = "Avg Layoff % of Workforce",
    color    = "Industry"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "right")

ggsave("charts/correlation_ai_vs_layoffs.png", width = 10, height = 6, dpi = 150)

cat("All charts saved to r/charts/\n")
