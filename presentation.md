---
title: "Payment Method Choice at Checkout"
subtitle: "Homework Assignment No. 2"
author: "Matias Arriagada R."
date: "May 2026"
institute: "Universidad de Concepción"
theme: "metropolis"
aspectratio: 169
header-includes: |
  \usepackage{booktabs}
  \usepackage{graphicx}
---

# Introduction & Phenomenon Identification

## Payment Method Choice at Checkout

### The Decision Context
At the checkout screen of an e-commerce platform, consumers make a discrete choice among several mutually exclusive payment methods.

### Why Study Payment Method Choice?
- **For Merchants**: Transaction fees vary (e.g., Credit Card 2% vs. UPI 0%). Merchant can steer choices.
- **For High-Value Segments (Electronics)**: Understand what features (speed, safety) attract buyers when spending large amounts.
- **For Checkout Design**: Reduce cart abandonment by minimizing friction.

### Econometric Modeling
- Matches utility maximization theory: $U_{ij} = V_{ij} + \epsilon_{ij}$.
- Incorporates alternative-specific attributes and individual characteristics.

---

# Data Selection & Source

## Relational Datasets merged on `customer_id`

### 1. Orders Dataset (`orders.csv`)
- **25,000 transactions**
- Contains choice variable (`payment_method`), transaction-level factors (`total_amount_usd`), and web metrics (`session_duration_minutes`).

### 2. Customers Dataset (`customers.csv`)
- **8,000 unique customers**
- Demographics (`age`, `gender`, `country`) and loyalty info (`membership_tier`).

### Choice Set & Attributes Definition
- **Top 4 Alternatives**: Credit Card, Debit Card, PayPal, UPI / Digital Wallet.
- **Calculated fee (`fee_usd`)**: Credit Card (2.0%), Debit Card (0.5%), PayPal (3.0%), UPI (0.0%).
- **Assumed speed (`processing_time`)**: UPI (1.5s) < Credit (2.0s) < Debit (2.5s) < PayPal (4.0s).
- **Assumed trust (`security_score`)**: PayPal (9.5) > Credit (9.0) > UPI (8.5) > Debit (8.0).

---

# Exploratory Data Analysis

## Sample Demographics and Market Shares

::: columns
::: {.column width="45%"}
### Choice Distribution (N = 3,594 Electronics Orders)
- **Credit Card**: 43.1%
- **Debit Card**: 25.3%
- **PayPal**: 19.8%
- **UPI / Wallet**: 11.8%

### High Value, High Homogeneity
- **Age**: Average age is ~35.7 years across all payment choices.
- **Order Value**: Mean order is very high (~$255) reflecting electronics prices.
:::
::: {.column width="55%"}
\begin{table}
\centering
\caption{Averages by Choice Group}
\tiny
\begin{tabular}{lrrr}
\toprule
Method & Mean Age & Pct Female & Mean Order \\
\midrule
Credit Card & 35.7 & 50.0\% & \$247.1 \\
Debit Card & 35.9 & 48.9\% & \$261.2 \\
PayPal & 35.3 & 51.2\% & \$257.5 \\
UPI / Wallet & 35.7 & 53.2\% & \$271.8 \\
\bottomrule
\end{tabular}
\end{table}

- Demographics and order values do not show strong direct correlations with choices, pointing to a balanced/randomized distribution.
:::
:::

---

# Data Visualization: Market Shares

## Distribution of Payment Choices

\begin{figure}
\centering
\includegraphics[width=0.7\textwidth]{output_plots/plot_choices.png}
\caption{Market Shares of Payment Alternatives}
\end{figure}

---

# Data Visualization: Demographics & Countries

## Choice by Membership Tier & Top Countries

::: columns
::: {.column width="50%"}
\begin{figure}
\centering
\includegraphics[width=1.0\textwidth]{output_plots/plot_choices_by_tier.png}
\caption{Market Share by Membership Tier}
\end{figure}
:::
::: {.column width="50%"}
\begin{figure}
\centering
\includegraphics[width=1.0\textwidth]{output_plots/plot_choices_by_country.png}
\caption{Market Share by Top 10 Countries}
\end{figure}
:::
:::

---

# Data Selection & Filters

## Establishing the Estimation Sample

### Why Filters are Necessary
To ensure our sample matches the econometric definition of a finalized checkout and a well-defined choice set.

### 1. Order Status Filter (Delivered/Returned)
- Excluded `Cancelled` and `Processing` orders since checkouts were not completed.

### 2. Category Filter (Electronics)
- Focused exclusively on the **Electronics** segment to reduce unobserved heterogeneity and analyze high-value purchases.

### 3. Choice Set Filter (Top 4 Payment Methods)
- Excluded Bank Transfer, BNPL, and Crypto due to low volumes.
- *Sample size*: **3,594 transactions** (Final Sample).

### Handling Missing Ratings & Outliers
- `customer_rating` has 11,723 missing records. Omitting them is unnecessary since ratings are post-purchase and do not affect checkout decisions.
- Outliers in transaction value (up to $2,730) are kept as they represent valid high-value orders and provide fee variance.

---

# Baseline Econometric Models

## Multinomial Logit (MNL) Models

### Model 1: Attribute-Only Model (No ASCs)
$$U_{ij} = \beta_{price} \cdot \text{fee\_usd}_{ij} + \beta_{time} \cdot \text{processing\_time}_j + \beta_{quality} \cdot \text{security\_score}_j + \gamma_j \cdot X_i + \epsilon_{ij}$$
- Isolates speed, cost, and safety attributes. UPI is used as the base.

### Model 2: Full Intercept Model (With ASCs)
$$U_{ij} = ASC_j + \beta_{price} \cdot \text{fee\_usd}_{ij} + \gamma_j \cdot X_i + \epsilon_{ij}$$
- Captures unobserved alternative-specific preferences. Credit Card is the base ($ASC = 0$).

---

# Estimation Results

## Model Comparison Summary

\begin{table}
\centering
\tiny
\begin{tabular}{lrrr}
\toprule
Variable & Model 1 (Base) & Model 2 (ASC) & Model 3 (Nested Logit) \\
\midrule
Time ($\beta_{time}$) & -0.2055 *** & -- & -0.2104 *** \\
Security ($\beta_{quality}$) & 0.4656 *** & -- & 0.4725 *** \\
Fee ($\beta_{price}$) & -0.0045 & -0.0035 & -0.0046 \\
\midrule
Log-Likelihood & -4,627.0 & -4,607.3 & -4,608.1 \\
AIC & 9,296.1 & 9,258.7 & 9,260.2 \\
\bottomrule
\end{tabular}
\end{table}

- **Time** is negative and highly significant.
- **Security** is positive and highly significant.
- **Nested Structure (LR Test)**: Nested Logit vastly outperforms MNL ($p = 7.42 \times 10^{-10}$).

---

# Willingness-to-Pay (WTP)

## Econometric Interpretation and Volatility

### Willingness-to-Pay Estimates (Model 1)
- **WTP for Speed**: $\$44.97$ (statistically unstable).
- **WTP for Security**: $-\$101.90$ (statistically unstable).

### Methodological Insights: Why are these values unstable?
- The price coefficient ($\beta_{price} = -0.0045$) is statistically indistinguishable from zero ($p = 0.508$).
- In synthetic data, payment choices were generated independently of the tiny transaction fees.
- When the cost coefficient is close to zero, dividing any other coefficient by it leads to extremely large and volatile values.
- **Key Takeaway**: A cost attribute must have a robustly identified, statistically significant negative coefficient to serve as a reliable numeraire for converting utility into monetary value.

---

# Conclusions & Future Research

## Summary of Findings

### 1. Focused Analysis on Electronics
- Isolated a clean sample of 3,594 electronics transactions.

### 2. Revealed True Decision Structure (Nested Logit)
- LR Tests strongly proved that consumers employ an explicitly nested decision-making process (Traditional Cards vs. Digital Wallets).

### 3. Confirmed Attribute Preferences
- Checkout speed and payment security are powerful drivers of consumer utility for high-ticket electronics purchases.

### 4. Econometric Insight on Cost Identification
- Uncovered that weakly identified price coefficients lead to unusable WTP estimations, highlighting a common hazard.
