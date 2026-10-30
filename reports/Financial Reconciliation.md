# RetailIQ — Financial Reconciliation Report

## 1. Objective

The objective of financial reconciliation is to validate financial figures across the cleaned sales and order-item datasets. This process helps identify inconsistencies in revenue, discounts, costs, and profit before performing business analysis.

## 2. Datasets Used

- `Cleaned_sales.csv`
- `Cleaned_order_items.csv`
- `Cleaned_product_catalog.csv`
- `Cleaned_customer_master.csv`

## 3. Financial Metrics

The following metrics are being independently calculated and validated:

- **Gross Sales:** Quantity multiplied by unit price, before discounts.
- **Discount Amount:** The discount applied to products or orders.
- **Net Sales:** Gross sales after discounts, following the dataset's definition of tax and shipping.
- **Product Cost:** Total cost of products sold.
- **Profit:** Revenue minus the relevant costs, using a consistent definition.
- **Average Order Value (AOV):** Eligible net sales divided by the number of eligible unique orders.
- **Return Rate:** Returned orders divided by eligible orders.
- **Cancellation Rate:** Cancelled orders divided by eligible orders.

## 4. Validation Methodology

1. Check the number of rows and the level of detail in each dataset.
2. Independently calculate gross sales and discount amounts from item-level data.
3. Aggregate item-level financial figures by order ID.
4. Compare item-level totals with the corresponding sales dataset totals.
5. Investigate missing values, duplicate order IDs, and mismatched financial figures.
6. Validate profit, AOV, return rate, and cancellation rate after confirming their definitions.

## 5. Reconciliation Results

| Metric | Sales Dataset | Order Items Dataset | Difference |
|---|---:|---:|---:|
| Gross Sales | Pending | Pending | Pending |
| Discount Amount | Pending | Pending | Pending |
| Net Sales | Pending | Pending | Pending |
| Product Cost | Pending | Pending | Pending |
| Profit | Pending | Pending | Pending |

*Note: Replace “Pending” with verified values after running the reconciliation code. Ensure both datasets use comparable definitions and aggregation levels.*

## 6. Issues Identified

Record any issues discovered during validation, such as:

- Differences between calculated and recorded gross sales.
- Differences in discount calculations.
- Mismatches between order-level and item-level totals.
- Missing or duplicate identifiers.
- Differences caused by tax, shipping, returns, cancellations, or calculation conventions.

No issue should be classified as a data error until it has been investigated.

## 7. Key Findings

To be completed after reconciliation.

- Total validated gross sales: Pending
- Total validated discounts: Pending
- Total validated net sales: Pending
- Total validated product cost: Pending
- Total validated profit: Pending
- Number of orders with unresolved financial differences: Pending

## 8. Conclusion

Financial reconciliation will establish a reliable foundation for RetailIQ's product performance, customer analysis, sales forecasting, and Power BI dashboard. Unresolved differences will be documented and investigated before the affected metrics are used for business decisions.