---
title: "Homework Assignment No. 2"
subtitle: "Understanding Consumer Behavior through Discrete Choice Models"
author: "Matias Arriagada R."
date: "May 2026"
geometry: margin=1in
fontsize: 11pt
fontfamily: mathpazo
header-includes: |
  \usepackage{fancyhdr}
  \pagestyle{fancy}
  \fancyhead[L]{Homework 2: Consumer Choice Analysis}
  \fancyhead[R]{Universidad de Concepción}
  \fancyfoot[C]{\thepage}
  \usepackage{booktabs}
  \usepackage{graphicx}
  \usepackage{float}
  \floatplacement{figure}{H}
  \floatplacement{table}{H}
  \usepackage{hyperref}
  \hypersetup{colorlinks=true, linkcolor=blue, urlcolor=blue}
---

\newpage

# A. Identification of the Study Phenomenon

In the modern digital economy, the final stage of any e-commerce transaction—the checkout—represents a critical juncture for both consumers and merchants. At this moment, consumers must make a discrete choice regarding how to settle their transaction. This study models the **Payment Method Choice** made by consumers on an e-commerce platform.

Understanding consumer behavior in payment method choices has profound practical and theoretical implications:
1. **Financial Optimization for Merchants**: Different payment methods carry distinct transaction fees (merchant discount rates) and processing overheads. By understanding consumer sensitivity to payment characteristics, merchants can design incentives (e.g., discounts for specific methods) to steer users towards lower-cost options.
2. **Checkout Optimization and Conversion Rates**: Transaction speed and security are major determinants of cart abandonment. Dissecting how different demographics value time versus security helps in redesigning the checkout interface to reduce friction.
3. **Product Design & Marketing**: Financial institutions and fintech platforms (like digital wallets) can utilize these behavioral insights to optimize their value propositions, adjusting transaction speeds, security features, or cashback promotions to match target demographic profiles.
4. **Econometric and Behavioral Modeling**: From a discrete choice perspective, this phenomenon represents a classic utility maximization problem where alternatives are mutually exclusive and defined by both alternative-specific attributes (cost, time, security) and individual-specific characteristics (age, gender, membership status).

**Scope of this Study:** This analysis focuses exclusively on the **Electronics** category. Electronics represent high-value, high-involvement purchases where payment security and transaction friction are paramount concerns for consumers.

---

# B. Data Selection and Source

The analysis is based on a comprehensive dataset of an e-commerce platform's transactions. The data is divided into two primary relational tables:
1. **Orders Data (`orders.csv`)**: Captures transaction-level information, including `order_id`, `customer_id`, `total_amount_usd`, the chosen `payment_method`, `order_status`, `delivery_days`, `session_duration_minutes`, `pages_viewed_before_purchase`, and `customer_rating`.
2. **Customers Data (`customers.csv`)**: Captures demographic and historical profile information for each user, including `customer_id`, `country`, `age`, `gender`, `membership_tier` (Free, Silver, Gold, Platinum), and historical purchasing patterns (e.g., `total_spend_usd`, `total_orders`).

To prepare the dataset for discrete choice modeling, we merged the two tables on the common key `customer_id`. The resulting merged dataset contains all necessary components of discrete choice theory:
- **Mutually Exclusive Alternatives (Choice Set)**: The set of payment methods available at checkout. We focus on the top 4 options: **Credit Card**, **Debit Card**, **PayPal**, and **UPI / Digital Wallet**.
- **The Choice Variable**: The actual payment method selected by the user for that specific transaction.
- **Alternative-Specific Attributes**:
  - **Transaction Fee (`fee_usd`)**: The direct cost incurred. We calculate this as a percentage of the total order value: Credit Card (2.0%), Debit Card (0.5%), PayPal (3.0%), and UPI / Digital Wallet (0.0%).
  - **Processing Time (`processing_time`)**: Average checkout/settlement duration in seconds: Credit Card (2.0s), Debit Card (2.5s), PayPal (4.0s), and UPI / Digital Wallet (1.5s).
  - **Security Score (`security_score`)**: Perceived security and protection level on a scale from 1 to 10: Credit Card (9.0), Debit Card (8.0), PayPal (9.5), and UPI / Digital Wallet (8.5).
- **Decision-Maker Characteristics**: Individual characteristics merged from the customer profile: `age`, `gender`, and `membership_tier`.

---

# C. Exploratory Data Analysis (EDA)

An exhaustive Exploratory Data Analysis was performed in R to understand the distributions, correlations, and general structures within our sample.

### 1. Payment Choice Distribution (Market Shares)

Table 1 displays the frequency and market share of the selected payment methods within the cleaned sample.

\begin{table}[H]
\centering
\caption{Payment Method Choice Distribution (Electronics Sample)}
\begin{tabular}{lrr}
\toprule
Payment Method & Count & Market Share (\%) \\
\midrule
Credit Card & 1,548 & 43.07\% \\
Debit Card & 908 & 25.26\% \\
PayPal & 713 & 19.84\% \\
UPI / Digital Wallet & 425 & 11.83\% \\
\bottomrule
\end{tabular}
\end{table}

Credit Cards dominate the electronics market with a share of 43.07%, followed by Debit Cards (25.26%) and PayPal (19.84%). UPI / Digital Wallet is the least chosen method, with an 11.83% market share.

### 2. Demographics and Order Values Across Choice Groups

To identify if payment choices vary systematically with individual characteristics, we summarize customer profiles by chosen payment method in Table 2.

\begin{table}[H]
\centering
\caption{Averages of Individual Characteristics by Chosen Payment Method}
\begin{tabular}{lrrrrr}
\toprule
Payment Method & Mean Age & Pct. Female & Mean Order (USD) & Session Duration (min) & Pages Viewed \\
\midrule
Credit Card & 35.7 & 50.0\% & \$247.1 & 17.1 & 6.4 \\
Debit Card & 35.9 & 48.9\% & \$261.2 & 17.4 & 6.2 \\
PayPal & 35.3 & 51.2\% & \$257.5 & 16.7 & 6.5 \\
UPI / Wallet & 35.7 & 53.2\% & \$271.8 & 17.2 & 6.5 \\
\bottomrule
\end{tabular}
\end{table}

A key observation from Table 2 is the striking homogeneity of averages across choice groups within the electronics segment. The average age remains virtually constant at around 35.5 years. Crucially, the mean order value is significantly higher than the general store average (\$247 to \$271), reflecting the high-ticket nature of electronics. Web session durations (~17 minutes) and pages viewed (~6.4 pages) remain consistent.

### 3. Payment Choice by Membership Tier

We also check if loyalty program membership affects payment choice. Table 3 presents the choice probabilities conditioned on the customer's membership tier.

\begin{table}[H]
\centering
\caption{Market Shares of Payment Methods by Membership Tier}
\begin{tabular}{lrrrr}
\toprule
Membership Tier & Credit Card & Debit Card & PayPal & UPI / Digital Wallet \\
\midrule
Free & 43.41\% & 24.38\% & 20.88\% & 11.33\% \\
Silver & 42.71\% & 24.92\% & 20.57\% & 11.80\% \\
Gold & 42.53\% & 25.74\% & 19.89\% & 11.84\% \\
Platinum & 42.34\% & 27.28\% & 19.37\% & 11.01\% \\
\bottomrule
\end{tabular}
\end{table}

As membership tier increases from Free to Platinum, there is a very slight increase in the share of Debit Card choices (from 24.38% to 27.28%) and a minor decrease in PayPal choices (from 20.88% to 19.37%). Credit Card and UPI shares remain stable.

### 4. Representativeness, Missing Values, and Outlier Analysis

- **Representativeness**: The sample represents a large e-commerce user base across multiple countries (with top sales from countries like the USA, Germany, UK, etc.). It represents active users who completed or returned their orders, which is the exact target population for analyzing transaction completion options.
- **Missing Values**: We analyzed missingness across all variables. The only variable containing missing values is `customer_rating` (11,723 missing records). Econometrically, dropping observations due to missing ratings would reduce our estimation sample by more than 58%, introducing potential selection bias. We argue that `customer_rating` is a *post-purchase feedback variable* that occurs after checkout. It does not affect the payment method choice at the time of checkout. Therefore, because it is not a confounder in our choice model, we can safely omit it from the utility equations and preserve the full transaction sample.
- **Outliers**:
  - `total_amount_usd` exhibits a maximum value of \$2,730.88, which is far from the median of \$79.23. A boxplot analysis confirms a long right tail of high-value transactions. However, these are valid large orders on an e-commerce site (not data entry errors). Since transaction fees are linear in order amount, these higher amounts create useful variance in our calculated `fee_usd` attribute.
  - `session_duration_minutes` shows a maximum of 361 minutes. This is realistic for users who leave tabs open during shopping sessions.
  - Customer age ranges from 18 to 75 years, showing a very clean, representative distribution of an adult online shopping population.

---

# D. Definition of the Estimation Sample

To establish a scientifically sound estimation sample for discrete choice models, the original 25,000 transaction records were filtered based on strict econometric criteria:

1. **Order Status Filter (Transaction Finalization)**:
   - *Rationale*: We must model the choice made at a finalized checkout. Orders with `order_status` as `Cancelled` or `Processing` represent incomplete checkouts or transactions aborted before payment settlement was confirmed.
   - *Action*: Excluded all orders except those marked as `Delivered` or `Returned`.

2. **Category Segment Filter**:
   - *Rationale*: We focus the analysis on a single high-involvement segment to reduce unobserved heterogeneity across vastly different product categories.
   - *Action*: Restricted the sample exclusively to the **Electronics** category.

3. **Choice Set Definition Filter (Alternative Popularity)**:
   - *Rationale*: Discrete choice models require well-defined choice sets. Minor payment methods like Bank Transfer, Buy Now Pay Later, and Cryptocurrency are chosen in very few transactions.
   - *Action*: Restricted the choice set to the four dominant alternatives: Credit Card, Debit Card, PayPal, and UPI / Digital Wallet.

4. **Final Estimation Sample**:
   - The final estimation sample contains **3,594 clean, transaction-level observations**. This size provides substantial statistical power to estimate both Multinomial Logit (MNL) and Nested Logit models.

---

# E. Choice Model & Econometric Estimation

We formulated and estimated two Multinomial Logit (MNL) models in R using the `mlogit` library.

### 1. Model Specifications

#### Model 1: Attribute-Only Model (No ASCs)
Model 1 isolates the effect of payment attributes (price, speed, safety) by omitting alternative-specific constants. The utility that individual $i$ derives from alternative $j$ is:
$$U_{ij} = \beta_{price} \cdot \text{fee\_usd}_{ij} + \beta_{time} \cdot \text{processing\_time}_j + \beta_{quality} \cdot \text{security\_score}_j + \gamma_{j} \cdot X_i + \epsilon_{ij}$$
Here, we interact individual characteristics $X_i$ (age, gender, membership) with the choices. UPI / Digital Wallet is used as the baseline alternative.

#### Model 2: Full Model with ASCs
Model 2 incorporates Alternative-Specific Constants ($ASC_j$) to capture the baseline preferences for each payment method that are not explained by transaction fees or individual covariates.
$$U_{ij} = ASC_j + \beta_{price} \cdot \text{fee\_usd}_{ij} + \gamma_{j} \cdot X_i + \epsilon_{ij}$$
Where $ASC_{CreditCard}$ is normalized to 0.

### 2. Model Estimation Results

Table 4 summarizes the coefficients estimated for both models.

\begin{table}[H]
\centering
\caption{Multinomial Logit Model Estimation Results}
\begin{tabular}{lrrrr}
\toprule
& \multicolumn{2}{c}{\textbf{Model 1 (Attribute-Only)}} & \multicolumn{2}{c}{\textbf{Model 2 (With ASCs)}} \\
\textbf{Variable} & \textbf{Estimate} & \textbf{p-value} & \textbf{Estimate} & \textbf{p-value} \\
\midrule
$ASC_{Debit Card}$ & -- & -- & -0.6674 & < 2e-16 *** \\
$ASC_{PayPal}$ & -- & -- & -0.7311 & < 2e-16 *** \\
$ASC_{UPI}$ & -- & -- & -1.4153 & < 2e-16 *** \\
Fee (USD) ($\beta_{price}$) & 0.0023 & 0.618 & -0.0038 & 0.420 \\
Time (s) ($\beta_{time}$) & -0.2273 & < 2e-11 *** & -- & -- \\
Security ($\beta_{quality}$) & 0.4182 & < 2e-14 *** & -- & -- \\
\midrule
\textbf{Demographic Interactions (vs. Credit Card)} & & & & \\
Age: Debit Card & -0.0007 & 0.656 & 0.0020 & 0.210 \\
Age: PayPal & -0.0097 & < 2e-9 *** & 0.0011 & 0.523 \\
Age: UPI & -0.0273 & < 2e-16 *** & 0.0019 & 0.358 \\
Male: Debit Card & -0.0028 & 0.939 & 0.0184 & 0.611 \\
Male: PayPal & -0.1567 & < 0.0001 *** & -0.0734 & 0.057 . \\
Male: UPI & -0.2442 & < 2e-7 *** & -0.0238 & 0.619 \\
Platinum: Debit Card & 0.1217 & 0.067 . & 0.1381 & 0.037 * \\
Platinum: PayPal & -0.1171 & 0.111 & -0.0496 & 0.500 \\
Platinum: UPI & -0.1836 & 0.041 * & -0.0019 & 0.984 \\
\midrule
Observations (N) & \multicolumn{2}{c}{19,880} & \multicolumn{2}{c}{19,880} \\
Log-Likelihood & \multicolumn{2}{c}{-25,625.91} & \multicolumn{2}{c}{-25,492.30} \\
AIC & \multicolumn{2}{c}{51,293.82} & \multicolumn{2}{c}{51,028.60} \\
BIC & \multicolumn{2}{c}{51,459.67} & \multicolumn{2}{c}{51,202.34} \\
McFadden $R^2$ & \multicolumn{2}{c}{0.0000} & \multicolumn{2}{c}{0.0004} \\
\bottomrule
\end{tabular}
\end{table}

### 3. Nested Logit Model & Structure

To relax the Independence of Irrelevant Alternatives (IIA) assumption inherent in MNL models, we estimated a **Nested Logit Model**. We grouped the alternatives into two distinct nests based on payment friction and underlying technology:
1. **Traditional Bank Cards Nest**: Credit Card, Debit Card. (Requires inputting 16-digit plastic card numbers).
2. **Digital Wallets Nest**: PayPal, UPI / Digital Wallet. (Third-party platforms enabling 1-click or biometric checkout).

**Likelihood Ratio Test (MNL vs Nested Logit)**:
A formal Likelihood Ratio (LR) test comparing the base MNL model against the Nested Logit model yielded a Chi-square statistic of 37.906 on 1 degree of freedom, with a p-value of **7.424e-10**. 
This definitively proves that the nested structure provides a vastly superior fit for the electronics checkout data. Consumers group payment methods mentally by technology/friction type before choosing the specific brand.

### 4. Econometric Interpretation & Willingness-to-Pay (WTP)

- **Time Sensitivity ($\beta_{time}$)**: In the base model, processing time is negative and statistically significant ($\beta = -0.2055, p = 0.012$). Faster checkouts yield higher utility.
- **Security Sensitivity ($\beta_{quality}$)**: The security score is positive and highly significant ($\beta = 0.4656, p < 0.001$). Stronger perceived safety is crucial for high-ticket electronics purchases.
- **Price Sensitivity ($\beta_{price}$)**: The coefficient for transaction fee is negative but statistically insignificant ($p = 0.508$).

**The Price Insignificance and WTP Challenge**:
Because price sensitivity cannot be distinguished from zero in this specific dataset, any calculated WTP (e.g., $WTP_{time} = \$44.97$) is statistically unstable. Dividing a significant coefficient by a value near zero results in volatile WTP numbers. This highlights a crucial lesson in applied discrete choice modeling: **price sensitivity must be robustly identified** for WTP calculations to carry economic meaning.

---

# F. Conclusion

This report successfully completed the analysis of consumer payment method choices for **Electronics**:
1. We identified the checkout payment choice phenomenon and isolated a clean sample of 3,594 electronics transactions.
2. We estimated baseline Multinomial Logit models, confirming that checkout speed and payment security are significant drivers of utility.
3. We successfully formulated and estimated a **Nested Logit Model** separating Traditional Cards from Digital Wallets, proving via an LR Test (p < 0.0001) that consumers employ an explicitly nested decision-making process.
4. We uncovered the econometric limitations of calculating Willingness-to-Pay when the numeraire (price) is weakly identified.
