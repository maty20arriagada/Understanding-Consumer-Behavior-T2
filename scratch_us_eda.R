# Load required libraries
library(dplyr)

# Load data
orders <- read.csv("orders.csv", stringsAsFactors = FALSE)
customers <- read.csv("customers.csv", stringsAsFactors = FALSE)

# Merge datasets
merged_data <- merge(orders, customers, by = "customer_id")

# Segment by Electronics category
elec_data <- merged_data %>% filter(category == "Electronics")

# Filter order_status as in the original script
elec_data <- elec_data %>% filter(order_status %in% c("Delivered", "Returned"))

# Filter payment_method
target_payments <- c("Credit Card", "Debit Card", "PayPal", "UPI / Digital Wallet")
elec_data <- elec_data %>% filter(payment_method %in% target_payments)

cat("Electronics Data Size:", nrow(elec_data), "\n")

cat("\nPayment Method Proportions:\n")
payment_props <- elec_data %>% group_by(payment_method) %>% summarise(Count = n()) %>% mutate(Proportion = Count / sum(Count))
print(payment_props)

cat("\nCross Proportions with Membership Tier:\n")
print(prop.table(table(elec_data$membership_tier, elec_data$payment_method), 1))

cat("\nCross Proportions with Device Used:\n")
print(prop.table(table(elec_data$device_used, elec_data$payment_method), 1))

cat("\nCross Proportions with Country:\n")
# Print top 5 countries
top_countries <- elec_data %>% group_by(country) %>% summarise(Count = n()) %>% arrange(desc(Count)) %>% head(5) %>% pull(country)
print(prop.table(table(elec_data$country, elec_data$payment_method), 1)[top_countries, ])
