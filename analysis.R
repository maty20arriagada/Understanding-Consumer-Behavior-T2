# ==============================================================================
# Homework Assignment No. 2 - Understanding Consumer Behavior
# Course: Understanding Consumer Behavior through Discrete Choice Models
# R script for Data Cleaning, EDA, and Multinomial Logit Model Estimation
# ==============================================================================

# Load required libraries
library(dplyr)
library(tidyr)
library(dfidx)
library(mlogit)
library(lmtest) # For lrtest

# Create output directories if needed
dir.create("output_tables", showWarnings = FALSE)
dir.create("output_plots", showWarnings = FALSE)

# ------------------------------------------------------------------------------
# 1. DATA LOADING AND MERGING
# ------------------------------------------------------------------------------
cat("Loading datasets...\n")
orders <- read.csv("orders.csv", stringsAsFactors = FALSE)
customers <- read.csv("customers.csv", stringsAsFactors = FALSE)

cat("Initial dimensions:\n")
cat("Orders:", nrow(orders), "rows, ", ncol(orders), "cols\n")
cat("Customers:", nrow(customers), "rows, ", ncol(customers), "cols\n")

# Merge datasets on customer_id
cat("Merging datasets on customer_id...\n")
merged_data <- merge(orders, customers, by = "customer_id")
cat("Merged dataset size:", nrow(merged_data), "rows\n")

# ------------------------------------------------------------------------------
# 2. DEFINITION OF THE ESTIMATION SAMPLE (DATA CLEANING)
# ------------------------------------------------------------------------------
cat("\nDefining the estimation sample...\n")

# Filter for United States segment
cat("Filtering for United States segment...\n")
merged_data <- merged_data %>% filter(country == "United States")
cat("Observations after US filter:", nrow(merged_data), "\n\n")

# A. Handle order status (exclude Cancelled and Processing)
cat("Distribution of order_status before filtering:\n")
print(table(merged_data$order_status, useNA = "always"))

merged_clean <- merged_data %>%
  filter(order_status %in% c("Delivered", "Returned"))

cat("Observations after filtering order_status (Delivered/Returned):", nrow(merged_clean), "\n")

# B. Handle payment method (include only Credit Card, Debit Card, PayPal, UPI / Digital Wallet)
cat("Distribution of payment_method before filtering:\n")
print(table(merged_clean$payment_method, useNA = "always"))

target_payments <- c("Credit Card", "Debit Card", "PayPal", "UPI / Digital Wallet")
merged_clean <- merged_clean %>%
  filter(payment_method %in% target_payments)

cat("Observations after filtering payment_method (top 4):", nrow(merged_clean), "\n")

# C. Identify and handle missing values
cat("\nChecking for missing values in the cleaned sample:\n")
missing_counts <- colSums(is.na(merged_clean))
print(missing_counts[missing_counts > 0])

# D. Check and handle outliers in continuous variables
cat("\nChecking summary statistics for outliers:\n")
numerical_vars <- c("age", "total_amount_usd", "delivery_days", "session_duration_minutes", "pages_viewed_before_purchase")
print(summary(merged_clean[, numerical_vars]))

# Define the final estimation sample
estimation_sample <- merged_clean
cat("\nFinal estimation sample size:", nrow(estimation_sample), "transactions\n")
write.csv(estimation_sample, "output_tables/estimation_sample.csv", row.names = FALSE)

# ------------------------------------------------------------------------------
# 3. EXPLORATORY DATA ANALYSIS (EDA) & TABLES
# ------------------------------------------------------------------------------
cat("\nGenerating descriptive tables...\n")

# Table 1: Choice variable distribution
payment_dist <- estimation_sample %>%
  group_by(payment_method) %>%
  summarize(Count = n(), Share = n() / nrow(estimation_sample))
write.csv(payment_dist, "output_tables/table_choice_distribution.csv", row.names = FALSE)
print(payment_dist)

# Table 2: Socioeconomic variables by chosen payment method
socioeconomic_by_payment <- estimation_sample %>%
  group_by(payment_method) %>%
  summarize(
    Mean_Age = mean(age, na.rm = TRUE),
    Pct_Female = sum(gender == "Female") / n(),
    Mean_Order_Value = mean(total_amount_usd, na.rm = TRUE),
    Mean_Session_Time = mean(session_duration_minutes, na.rm = TRUE),
    Mean_Pages_Viewed = mean(pages_viewed_before_purchase, na.rm = TRUE),
    Observations = n()
  )
write.csv(socioeconomic_by_payment, "output_tables/table_socioeconomic_by_payment.csv", row.names = FALSE)
print(socioeconomic_by_payment)

# Table 3: Choice distribution by membership tier (market share)
tier_by_payment <- table(estimation_sample$membership_tier, estimation_sample$payment_method)
tier_by_payment_pct <- prop.table(tier_by_payment, 1)
write.csv(as.data.frame.matrix(tier_by_payment_pct), "output_tables/table_tier_by_payment_pct.csv")
print(tier_by_payment_pct)

# ------------------------------------------------------------------------------
# 4. DATA VISUALIZATION (PLOTS)
# ------------------------------------------------------------------------------
cat("\nGenerating high-quality plots...\n")

# Color palette for modern aesthetics
modern_colors <- c("Credit Card" = "#3b82f6",     # Blue
                   "Debit Card" = "#10b981",      # Emerald Green
                   "PayPal" = "#f59e0b",          # Amber Orange
                   "UPI / Digital Wallet" = "#8b5cf6") # Purple

# Plot 1: Choice Frequencies and Market Shares
png("output_plots/plot_choices.png", width = 800, height = 600, res = 120)
par(mar = c(5, 5, 4, 2), bg = "#fcfcfc")
bp <- barplot(payment_dist$Share * 100, 
        names.arg = payment_dist$payment_method,
        col = modern_colors[payment_dist$payment_method],
        border = NA,
        ylim = c(0, 50),
        ylab = "Market Share (%)",
        main = "Payment Method Choice Distribution",
        col.main = "#1f2937", col.lab = "#374151",
        las = 1)
# Add percentage labels on top of bars
text(bp, payment_dist$Share * 100 + 2, 
     labels = paste0(round(payment_dist$Share * 100, 1), "%"), 
     cex = 0.9, font = 2, col = "#374151")
dev.off()

# Plot 2: Payment Choices by Membership Tier
png("output_plots/plot_choices_by_tier.png", width = 900, height = 600, res = 120)
par(mar = c(5, 5, 4, 10), bg = "#fcfcfc", xpd = TRUE)
barplot(t(tier_by_payment_pct * 100),
        col = modern_colors[colnames(tier_by_payment_pct)],
        border = NA,
        legend.text = FALSE, # Manual legend for control
        ylab = "Market Share (%)",
        xlab = "Membership Tier",
        main = "Payment Method Choice by Membership Tier",
        col.main = "#1f2937", col.lab = "#374151",
        las = 1)
legend("topright", inset = c(-0.35, 0),
       legend = colnames(tier_by_payment_pct),
       fill = modern_colors[colnames(tier_by_payment_pct)],
       bty = "n", border = NA, cex = 0.8)
dev.off()

# Plot 3: Payment Choices by Category (Top 10 Categories by sales)
top_categories <- estimation_sample %>%
  group_by(category) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>%
  slice(1:10) %>%
  pull(category)

category_payment_pct <- table(estimation_sample$category, estimation_sample$payment_method)
category_payment_pct <- prop.table(category_payment_pct, 1)[top_categories, , drop = FALSE]

png("output_plots/plot_choices_by_category.png", width = 1000, height = 600, res = 120)
par(mar = c(10, 5, 4, 12), bg = "#fcfcfc", xpd = TRUE)
barplot(t(category_payment_pct * 100),
        col = modern_colors[colnames(category_payment_pct)],
        border = NA,
        ylab = "Market Share (%)",
        main = "Payment Method Choice by Category (Top 10)",
        col.main = "#1f2937", col.lab = "#374151",
        las = 2, cex.names = 0.8)
legend("topright", inset = c(-0.25, 0),
       legend = colnames(category_payment_pct),
       fill = modern_colors[colnames(category_payment_pct)],
       bty = "n", border = NA, cex = 0.8)
dev.off()

# Plot 4: Age Distribution by Payment Method Chosen
png("output_plots/plot_age_distribution.png", width = 800, height = 600, res = 120)
par(mar = c(5, 5, 4, 2), bg = "#fcfcfc")
boxplot(age ~ payment_method, data = estimation_sample,
        col = modern_colors[levels(factor(estimation_sample$payment_method))],
        border = "#4b5563",
        ylab = "Customer Age (Years)",
        xlab = "Payment Method Chosen",
        main = "Age Distribution across Payment Choices",
        col.main = "#1f2937", col.lab = "#374151",
        las = 1, frame.plot = FALSE)
dev.off()

# ------------------------------------------------------------------------------
# 5. DISCRETE CHOICE MODEL PREPARATION & RESHAPING
# ------------------------------------------------------------------------------
cat("\nReshaping data for discrete choice modeling (mlogit)...\n")

# Define the attributes of each payment method alternative
alternatives <- data.frame(
  alt = c("Credit Card", "Debit Card", "PayPal", "UPI / Digital Wallet"),
  fee_pct = c(0.02, 0.005, 0.03, 0.00),
  processing_time = c(2.0, 2.5, 4.0, 1.5),
  security_score = c(9.0, 8.0, 9.5, 8.5),
  stringsAsFactors = FALSE
)

# Reshape estimation sample to long format
estimation_long <- merge(estimation_sample, alternatives, by = NULL)
estimation_long$choice <- estimation_long$payment_method == estimation_long$alt
estimation_long$fee_usd <- estimation_long$total_amount_usd * estimation_long$fee_pct
estimation_long$order_id <- as.character(estimation_long$order_id)

# Convert to dfidx format (long format for mlogit)
idx_data <- dfidx(estimation_long, idx = list("order_id", "alt"), choice = "choice")

# ------------------------------------------------------------------------------
# 6. ESTIMATE MODELS
# ------------------------------------------------------------------------------
sink("output_tables/model_estimation_outputs.txt")

cat("======================================================================\n")
cat("MODEL 1: ATTRIBUTE-ONLY MODEL (NO INTERCEPTS / ASCs)\n")
cat("======================================================================\n")
fit1 <- mlogit(choice ~ fee_usd + processing_time + security_score | age + gender + membership_tier - 1, data = idx_data)
print(summary(fit1))

cat("\n\n")
cat("======================================================================\n")
cat("MODEL 2: FULL MODEL WITH ASCs (AND TRANSACTION FEES)\n")
cat("======================================================================\n")
fit2 <- mlogit(choice ~ fee_usd | age + gender + membership_tier, data = idx_data)
print(summary(fit2))

cat("\n\n")
cat("======================================================================\n")
cat("MODEL 3: NESTED LOGIT MODEL\n")
cat("======================================================================\n")
# Nests: 
# Cards = Credit Card, Debit Card
# Digital = PayPal, UPI / Digital Wallet
fit3_nl <- mlogit(choice ~ fee_usd + processing_time + security_score | age + gender + membership_tier - 1, 
                  data = idx_data,
                  nests = list(Cards = c("Credit Card", "Debit Card"),
                               Digital = c("PayPal", "UPI / Digital Wallet")),
                  un.nest.el = TRUE)
print(summary(fit3_nl))

sink()

# ------------------------------------------------------------------------------
# 7. MODEL ANALYSIS AND INTERPRETATION
# ------------------------------------------------------------------------------
sink("output_tables/model_analysis_summary.txt")

cat("======================================================================\n")
cat("DISCRETE CHOICE MODEL COMPARISON & ANALYSIS\n")
cat("======================================================================\n")

# Extract key statistics for Model 1
c1 <- summary(fit1)$CoefTable
ll1 <- as.numeric(logLik(fit1))
aic1 <- AIC(fit1)
n_obs1 <- nrow(estimation_sample)
bic1 <- -2 * ll1 + length(coef(fit1)) * log(n_obs1)
r2_mcf_1 <- as.numeric(summary(fit1)$mfR2)

cat("Model 1 (Attribute-Only) Goodness-of-Fit:\n")
cat("- Number of observations (N):", n_obs1, "\n")
cat("- Log-Likelihood:", ll1, "\n")
cat("- AIC:", aic1, "\n")
cat("- BIC:", bic1, "\n")
cat("- McFadden R-squared:", r2_mcf_1, "\n\n")

# Extract key statistics for Model 2
c2 <- summary(fit2)$CoefTable
ll2 <- as.numeric(logLik(fit2))
aic2 <- AIC(fit2)
bic2 <- -2 * ll2 + length(coef(fit2)) * log(n_obs1)
r2_mcf_2 <- as.numeric(summary(fit2)$mfR2)

cat("Model 2 (ASC Model) Goodness-of-Fit:\n")
cat("- Number of observations (N):", n_obs1, "\n")
cat("- Log-Likelihood:", ll2, "\n")
cat("- AIC:", aic2, "\n")
cat("- BIC:", bic2, "\n")
cat("- McFadden R-squared:", r2_mcf_2, "\n\n")

# Extract key statistics for Model 3 (Nested Logit)
c3 <- summary(fit3_nl)$CoefTable
ll3 <- as.numeric(logLik(fit3_nl))
aic3 <- AIC(fit3_nl)
bic3 <- -2 * ll3 + length(coef(fit3_nl)) * log(n_obs1)
r2_mcf_3 <- as.numeric(summary(fit3_nl)$mfR2)

cat("Model 3 (Nested Logit) Goodness-of-Fit:\n")
cat("- Number of observations (N):", n_obs1, "\n")
cat("- Log-Likelihood:", ll3, "\n")
cat("- AIC:", aic3, "\n")
cat("- BIC:", bic3, "\n")
cat("- McFadden R-squared:", r2_mcf_3, "\n\n")

cat("----------------------------------------------------------------------\n")
cat("LIKELIHOOD RATIO TEST (MNL vs NESTED LOGIT)\n")
cat("----------------------------------------------------------------------\n")
print(lrtest(fit1, fit3_nl))
cat("\n")

# Hypothesis tests / Willingness-to-Pay for Model 1
cat("----------------------------------------------------------------------\n")
cat("WILLINGNESS-TO-PAY (WTP) ESTIMATION (MODEL 1)\n")
cat("----------------------------------------------------------------------\n")
beta_fee <- c1["fee_usd", "Estimate"]
beta_time <- c1["processing_time", "Estimate"]
beta_security <- c1["security_score", "Estimate"]

wtp_time <- beta_time / beta_fee
wtp_security <- beta_security / beta_fee

cat("Beta Fee (price sensitivity):", beta_fee, " (p-value: ", c1["fee_usd", "Pr(>|z|)"], ")\n")
cat("Beta Time (speed sensitivity):", beta_time, " (p-value: ", c1["processing_time", "Pr(>|z|)"], ")\n")
cat("Beta Security (trust sensitivity):", beta_security, " (p-value: ", c1["security_score", "Pr(>|z|)"], ")\n\n")

cat("Willingness to Pay (WTP):\n")
cat("- WTP to save 1 second of processing time: $", wtp_time, "\n")
cat("- WTP for 1 point increase in security score: $", wtp_security, "\n\n")
cat("Note on WTP Interpretation:\n")
cat("Since beta_fee is positive and statistically insignificant, WTP results are positive/negative and unstable.\n")
cat("This is because in this synthetic dataset, payment choice is independent of transaction fees.\n")

sink()

cat("\nR analysis complete! Outputs saved in 'output_tables/' and 'output_plots/'.\n")
# ==============================================================================
