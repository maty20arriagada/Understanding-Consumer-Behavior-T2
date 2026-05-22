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
- **For Fintechs & Banks**: Understand what features (speed, safety, fees) attract users.
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
### Choice Distribution (N = 19,880)
- **Credit Card**: 43.04%
- **Debit Card**: 24.93%
- **PayPal**: 20.54%
- **UPI / Wallet**: 11.48%

### High Demographic Homogeneity
- **Age**: Average age is ~35.5 years across all payment choices.
- **Gender**: Female percentage is ~48-50% in all groups.
- **Order Value**: Mean order is ~$126 across all groups.
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
Credit Card & 35.41 & 48.7\% & \$126.26 \\
Debit Card & 35.67 & 48.2\% & \$127.34 \\
PayPal & 35.56 & 50.4\% & \$124.90 \\
UPI / Wallet & 35.67 & 49.1\% & \$127.15 \\
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
- Excluded `Cancelled` (1,456) and `Processing` (1,027) orders since checkouts were not completed.
- *Sample size*: 25,000 $\rightarrow$ 22,517.

### 2. Choice Set Filter (Top 4 Payment Methods)
- Excluded Bank Transfer (832), BNPL (1,358), and Crypto (447) due to low volumes (<12% combined).
- *Sample size*: 22,517 $\rightarrow$ **19,880 transactions** (Final Sample).

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
\begin{tabular}{lrrrr}
\toprule
& \multicolumn{2}{c}{\textbf{Model 1 (Attribute-Only)}} & \multicolumn{2}{c}{\textbf{Model 2 (With ASCs)}} \\
Variable & Estimate & p-value & Estimate & p-value \\
\midrule
$ASC_{Debit Card}$ & -- & -- & -0.6674 & < 2e-16 *** \\
$ASC_{PayPal}$ & -- & -- & -0.7311 & < 2e-16 *** \\
$ASC_{UPI}$ & -- & -- & -1.4153 & < 2e-16 *** \\
Fee (USD) ($\beta_{price}$) & 0.0023 & 0.618 & -0.0038 & 0.420 \\
Time (s) ($\beta_{time}$) & -0.2273 & < 2e-11 *** & -- & -- \\
Security ($\beta_{quality}$) & 0.4182 & < 2e-14 *** & -- & -- \\
\midrule
Log-Likelihood & \multicolumn{2}{c}{-25,625.91} & \multicolumn{2}{c}{-25,492.30} \\
AIC / BIC & \multicolumn{2}{c}{51,293.82 / 51,459.67} & \multicolumn{2}{c}{51,028.60 / 51,202.34} \\
McFadden $R^2$ & \multicolumn{2}{c}{0.0000} & \multicolumn{2}{c}{0.0004} \\
\bottomrule
\end{tabular}
\end{table}

- **Time** is negative and highly significant.
- **Security** is positive and highly significant.
- **Fee** is statistically insignificant in both models.

---

# Willingness-to-Pay (WTP)

## Econometric Interpretation and Volatility

### Willingness-to-Pay Estimates (Model 1)
- **WTP for Speed**: $-\$98.51$ per second saved (implied sign-flip).
- **WTP for Security**: $\$181.23$ per unit of security increase.

### Methodological Insights: Why are these values unstable?
- The price coefficient ($\beta_{price} = 0.0023$) is statistically indistinguishable from zero ($p = 0.618$).
- In synthetic data, payment choices were generated independently of the tiny transaction fees.
- When the cost coefficient is close to zero, dividing any other coefficient by it leads to extremely large and volatile values.
- **Key Takeaway**: A cost attribute must have a robustly identified, statistically significant negative coefficient to serve as a reliable numeraire for converting utility into monetary value.

---

# Conclusions & Future Research

## Summary of Findings

### 1. Successful Setup of Choice Framework
- Merged relational data and defined an estimation sample of 19,880 clean checkouts.
- Defended decision to keep observations with missing customer ratings.

### 2. Confirmed Attribute Preferences
- Checkout speed and payment security are powerful drivers of consumer utility.

### 3. Econometric Insight on Cost Identification
- Uncovered that weakly identified price coefficients lead to unusable WTP estimations, highlighting a common hazard in discrete choice modeling.

### 4. Next Steps for Homework 3
- Introduce Nested Logit models (grouping Cards vs. Digital/Third Party methods).
- Explore interaction terms to capture segment-specific cost sensitivities.
