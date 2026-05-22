# Load required libraries
library(dplyr)

# Load data
orders <- read.csv("orders.csv", stringsAsFactors = FALSE)
customers <- read.csv("customers.csv", stringsAsFactors = FALSE)

# Merge datasets
merged_data <- merge(orders, customers, by = "customer_id")

# Segment by United States
us_data <- merged_data %>% filter(country == "United States")

# Filter order_status as in the original script
us_data <- us_data %>% filter(order_status %in% c("Delivered", "Returned"))

# Filter payment_method
target_payments <- c("Credit Card", "Debit Card", "PayPal", "UPI / Digital Wallet")
us_data <- us_data %>% filter(payment_method %in% target_payments)

cat("US Data Size:", nrow(us_data), "\n")

cat("\nPayment Method Proportions:\n")
payment_props <- us_data %>% group_by(payment_method) %>% summarise(Count = n()) %>% mutate(Proportion = Count / sum(Count))
print(payment_props)

cat("\nCross Proportions with Membership Tier:\n")
print(prop.table(table(us_data$membership_tier, us_data$payment_method), 1))

cat("\nCross Proportions with Device Used:\n")
print(prop.table(table(us_data$device_used, us_data$payment_method), 1))

cat("\nCross Proportions with Category:\n")
print(prop.table(table(us_data$category, us_data$payment_method), 1))
