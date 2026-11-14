SHOW DATABASES;
USE supply_chain_data;
SHOW TABLES;
SELECT COUNT(*) AS total_records
FROM supply_chain_clean_data;
DESCRIBE supply_chain_clean_data;

-- Step 1: Overall business performance
SELECT
    COUNT(*) AS Total_Records,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(AVG(Sales), 2) AS Average_Sales,
    ROUND(AVG(`Order Profit Per Order`), 2) AS Average_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100, 2
    ) AS Overall_Profit_Margin
FROM supply_chain_clean_data;

-- Step 2: Analyse shipping performance
SELECT
    CASE
        WHEN `Days for shipping (real)` >
             `Days for shipment (scheduled)`
            THEN 'Late'
        WHEN `Days for shipping (real)` <
             `Days for shipment (scheduled)`
            THEN 'Early'
        ELSE 'On Time'
    END AS Shipping_Performance,

    COUNT(*) AS Total_Records,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM supply_chain_clean_data),
        2
    ) AS Percentage

FROM supply_chain_clean_data
GROUP BY Shipping_Performance
ORDER BY Total_Records DESC;

-- Step 3: Analyse shipping performance by shipping mode
SELECT
    `Shipping Mode`,
    COUNT(*) AS Total_Orders,

    SUM(
        CASE
            WHEN `Days for shipping (real)` >
                 `Days for shipment (scheduled)`
            THEN 1 ELSE 0
        END
    ) AS Late_Orders,

    ROUND(
        SUM(
            CASE
                WHEN `Days for shipping (real)` >
                     `Days for shipment (scheduled)`
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Late_Delivery_Percentage

FROM supply_chain_clean_data
GROUP BY `Shipping Mode`
ORDER BY Late_Delivery_Percentage DESC;

-- Step 4: Analyse profitability by shipping mode
SELECT
    `Shipping Mode`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin

FROM supply_chain_clean_data
GROUP BY `Shipping Mode`
ORDER BY Total_Profit DESC;

-- Step 5: Analyse profitability by product category
SELECT
    `Category Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin

FROM supply_chain_clean_data
GROUP BY `Category Name`
ORDER BY Total_Profit DESC;

-- Step 6: Identify the five lowest-profit categories
SELECT
    `Category Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Category Name`
ORDER BY Total_Profit ASC
LIMIT 5;

-- Step 7: Customer segment profitability analysis
SELECT
    `Customer Segment`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Customer Segment`
ORDER BY Total_Profit DESC;

-- Step 8: Market-wise profitability analysis
SELECT
    Market,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY Market
ORDER BY Total_Profit DESC;

-- Step 9: Analyse profitability by order status
SELECT
    `Order Status`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Order Status`
ORDER BY Total_Orders DESC;

-- Step 10: Analyse discount impact on profitability
SELECT
    `Discount Band`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Discount Band`
ORDER BY Profit_Margin DESC;

-- Step 11: Profitability by shipping performance
SELECT
    `Shipping Performance`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Shipping Performance`
ORDER BY Profit_Margin DESC;

-- Step 12: Market-wise shipping performance
SELECT
    Market,
    `Shipping Performance`,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Market),
        2
    ) AS Percentage
FROM supply_chain_clean_data
GROUP BY Market, `Shipping Performance`
ORDER BY Market, Total_Orders DESC;

-- Step 13: Market and shipping mode performance
SELECT
    Market,
    `Shipping Mode`,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN `Shipping Performance` = 'Late'
            THEN 1 ELSE 0
        END
    ) AS Late_Orders,
    ROUND(
        SUM(
            CASE
                WHEN `Shipping Performance` = 'Late'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Late_Delivery_Percentage,
    ROUND(AVG(`Shipping Delay Days`), 2) AS Average_Delay_Days
FROM supply_chain_clean_data
GROUP BY Market, `Shipping Mode`
ORDER BY Late_Delivery_Percentage DESC;

-- step 14: Customer and product profitability analysis
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
ORDER BY Total_Profit DESC
LIMIT 10;

-- step 15: Identify the 10 least profitable customers
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
ORDER BY Total_Profit ASC
LIMIT 10;

-- Step 16: Product profitability analysis
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Product Name`
ORDER BY Total_Profit DESC
LIMIT 10;

-- Step 17: Identify the 10 least profitable products
SELECT 
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(SUM(`Order Profit Per Order`) / NULLIF(SUM(`Sales`), 0) * 100,
            2) AS Profit_Margin
FROM
    supply_chain_clean_data
GROUP BY `Product Name`
ORDER BY Total_Profit ASC
LIMIT 10;

-- Step 18: Analyse profitability by department
SELECT
    `Department Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Department Name`
ORDER BY Total_Profit DESC;

-- Step 19: Analyse profitability by order value
SELECT
    `Order Value Band`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Order Value Band`
ORDER BY Total_Sales DESC;

-- Step 20: Analyse profitability by discount band
SELECT
    `Discount Band`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Discount Band`
ORDER BY Profit_Margin DESC;

-- Step 21: Discount impact across shipping modes
SELECT
    `Shipping Mode`,
    `Discount Band`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Shipping Mode`, `Discount Band`
ORDER BY `Shipping Mode`, Profit_Margin DESC;

-- Step 22: Customer profitability analysis
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
ORDER BY Total_Profit DESC
LIMIT 10;

-- Step 23: Identify the 10 least profitable customers
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
ORDER BY Total_Profit ASC
LIMIT 10;

-- Step 24: Product-level loss analysis
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Product Name`
ORDER BY Total_Profit ASC
LIMIT 10;

-- Step 25: Department-level profitability analysis
SELECT
    `Department Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Department Name`
ORDER BY Total_Profit DESC;

-- Step 26: Overall shipping delay analysis
SELECT
    ROUND(AVG(`Days for shipping (real)`), 2) AS Avg_Actual_Shipping_Days,
    ROUND(AVG(`Days for shipment (scheduled)`), 2) AS Avg_Scheduled_Shipping_Days,
    ROUND(
        AVG(`Days for shipping (real)`) -
        AVG(`Days for shipment (scheduled)`), 2
    ) AS Average_Delay_Days,
    MAX(`Days for shipping (real)`) AS Maximum_Shipping_Days
FROM supply_chain_clean_data;

-- Step 27: Profitability by customer
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
ORDER BY Total_Profit DESC
LIMIT 10;

-- Step 28: Customer profitability classification
SELECT
    Customer_Status,
    COUNT(*) AS Total_Customers
FROM (
    SELECT
        `Customer Id`,
        CASE
            WHEN SUM(`Order Profit Per Order`) > 0
                THEN 'Profitable Customer'
            WHEN SUM(`Order Profit Per Order`) < 0
                THEN 'Loss-Making Customer'
            ELSE 'Break-Even Customer'
        END AS Customer_Status
    FROM supply_chain_clean_data
    GROUP BY `Customer Id`
) AS Customer_Summary
GROUP BY Customer_Status;

-- Step 29: Identify the most loss-making products
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit
FROM supply_chain_clean_data
GROUP BY `Product Name`
HAVING SUM(`Order Profit Per Order`) < 0
ORDER BY Total_Profit ASC
LIMIT 10;

-- Step 30: Analyse discounts on loss-making products
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(`Order Item Discount Rate`) * 100, 2) AS Average_Discount_Pct,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit
FROM supply_chain_clean_data
WHERE `Product Name` IN (
    'SOLE E35 Elliptical',
    'Bushnell Pro X7 Jolt Slope Rangefinder',
    'SOLE E25 Elliptical'
)
GROUP BY `Product Name`;

-- Step 31: Overall profitability by department
SELECT
    `Department Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Department Name`
ORDER BY Total_Profit DESC;

-- Step 32: Category-wise profitability across markets
SELECT
    `Market`,
    `Category Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Market`,
    `Category Name`
ORDER BY
    `Market`,
    Total_Profit DESC;

-- step 33: Find the best-performing market-category combinations
SELECT
    `Market`,
    `Category Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Market`, `Category Name`
HAVING COUNT(*) >= 100
ORDER BY Profit_Margin DESC
LIMIT 10;

-- Step 34: Identify loss-making departments
SELECT
    `Department Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Department Name`
ORDER BY Total_Profit ASC;

-- step 35: Customer profitability analysis
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
ORDER BY Total_Profit DESC
LIMIT 10;

-- step 36: Identify loss-making customers
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
HAVING SUM(`Order Profit Per Order`) < 0
ORDER BY Total_Profit ASC
LIMIT 10;

-- Step 37: Customer profitability classification
SELECT
    Customer_Status,
    COUNT(*) AS Total_Customers
FROM (
    SELECT
        CASE
            WHEN SUM(`Order Profit Per Order`) > 0
                THEN 'Profitable Customer'
            WHEN SUM(`Order Profit Per Order`) < 0
                THEN 'Loss-Making Customer'
            ELSE 'Break-Even Customer'
        END AS Customer_Status
    FROM supply_chain_clean_data
    GROUP BY `Customer Id`
) AS Customer_Summary
GROUP BY Customer_Status;

-- Step 38: Customer segment profitability analysis
SELECT
    `Customer Segment`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Customer Segment`
ORDER BY Total_Profit DESC;

-- Step 39: Market-wise profitability analysis
SELECT
    `Market`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Market`
ORDER BY Total_Profit DESC;

-- Step 40: Shipping Mode and Discount Band Profitability
SELECT
    `Shipping Mode`,
    `Discount Band`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Shipping Mode`,
    `Discount Band`
ORDER BY
    `Shipping Mode`,
    Profit_Margin DESC;
    
    -- Step 41: Shipping Delay Analysis by Market
SELECT
    `Market`,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(`Days for shipping (real)`), 2)
        AS Avg_Actual_Shipping_Days,
    ROUND(AVG(`Days for shipment (scheduled)`), 2)
        AS Avg_Scheduled_Shipping_Days,
    ROUND(
        AVG(`Days for shipping (real)`) -
        AVG(`Days for shipment (scheduled)`), 2
    ) AS Avg_Shipping_Delay
FROM supply_chain_clean_data
GROUP BY `Market`
ORDER BY Avg_Shipping_Delay DESC;

-- Step 42: Late Shipment Rate by Market
SELECT
    `Market`,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN `Days for shipping (real)` >
                 `Days for shipment (scheduled)`
            THEN 1 ELSE 0
        END
    ) AS Late_Orders,
    ROUND(
        SUM(
            CASE
                WHEN `Days for shipping (real)` >
                     `Days for shipment (scheduled)`
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS Late_Shipment_Rate
FROM supply_chain_clean_data
GROUP BY `Market`
ORDER BY Late_Shipment_Rate DESC;

-- Step 43: Profitability by Shipping Performance
SELECT
    CASE
        WHEN `Days for shipping (real)` >
             `Days for shipment (scheduled)`
        THEN 'Late'
        WHEN `Days for shipping (real)` <
             `Days for shipment (scheduled)`
        THEN 'Early'
        ELSE 'On Time'
    END AS Shipping_Performance,

    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin

FROM supply_chain_clean_data

GROUP BY Shipping_Performance
ORDER BY Total_Profit DESC;

-- Step 44: Top 10 Most Profitable Customers
SELECT
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Customer Id`,
    `Customer Fname`,
    `Customer Lname`
ORDER BY Total_Profit DESC
LIMIT 10;

-- Step 45: Identify top 10 profitable products
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Product Name`
ORDER BY Total_Profit DESC
LIMIT 10;

-- Step 46: Identify loss-making products
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit
FROM supply_chain_clean_data
GROUP BY `Product Name`
HAVING SUM(`Order Profit Per Order`) < 0
ORDER BY Total_Profit ASC
LIMIT 10;

-- Step 47: Product discount and profitability analysis
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(`Order Item Discount Rate`) * 100, 2)
        AS Average_Discount_Pct,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Product Name`
HAVING COUNT(*) >= 100
ORDER BY Average_Discount_Pct DESC
LIMIT 10;

-- Step 48: Identify products with highest profit margins
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Product Name`
HAVING COUNT(*) >= 100
   AND SUM(`Sales`) > 0
ORDER BY Profit_Margin DESC
LIMIT 10;

-- Step 49: Product profitability by shipping mode
SELECT
    `Product Name`,
    `Shipping Mode`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Product Name`,
    `Shipping Mode`
HAVING COUNT(*) >= 100
ORDER BY Profit_Margin ASC
LIMIT 15;

-- Step 50: Highest-margin product and shipping combinations
SELECT
    `Product Name`,
    `Shipping Mode`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Product Name`,
    `Shipping Mode`
HAVING COUNT(*) >= 100
ORDER BY Profit_Margin DESC
LIMIT 15;

-- Step 51: High-sales products with low profit margins
SELECT
    `Product Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY `Product Name`
HAVING COUNT(*) >= 100
   AND SUM(`Sales`) > 10000
ORDER BY Profit_Margin ASC
LIMIT 15;

-- Step 52: Late shipment analysis by product category
SELECT
    `Category Name`,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN `Days for shipping (real)` >
                 `Days for shipment (scheduled)`
            THEN 1 ELSE 0
        END
    ) AS Late_Orders,
    ROUND(
        SUM(
            CASE
                WHEN `Days for shipping (real)` >
                     `Days for shipment (scheduled)`
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS Late_Shipment_Rate
FROM supply_chain_clean_data
GROUP BY `Category Name`
ORDER BY Late_Shipment_Rate DESC;

-- Step 53: High-volume categories with late shipments
SELECT
    `Category Name`,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN `Days for shipping (real)` >
                 `Days for shipment (scheduled)`
            THEN 1 ELSE 0
        END
    ) AS Late_Orders,
    ROUND(
        SUM(
            CASE
                WHEN `Days for shipping (real)` >
                     `Days for shipment (scheduled)`
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS Late_Shipment_Rate
FROM supply_chain_clean_data
GROUP BY `Category Name`
HAVING COUNT(*) >= 500
ORDER BY Late_Shipment_Rate DESC;

-- Step 54: Categories contributing the highest number of late orders
SELECT
    `Category Name`,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN `Days for shipping (real)` >
                 `Days for shipment (scheduled)`
            THEN 1 ELSE 0
        END
    ) AS Late_Orders,
    ROUND(
        SUM(
            CASE
                WHEN `Days for shipping (real)` >
                     `Days for shipment (scheduled)`
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS Late_Shipment_Rate
FROM supply_chain_clean_data
GROUP BY `Category Name`
ORDER BY Late_Orders DESC
LIMIT 10;
-- Step 55: Late shipment analysis by shipping mode and category

SELECT
    `Shipping Mode`,
    `Category Name`,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN `Days for shipping (real)` >
                 `Days for shipment (scheduled)`
            THEN 1 ELSE 0
        END
    ) AS Late_Orders,
    ROUND(
        SUM(
            CASE
                WHEN `Days for shipping (real)` >
                     `Days for shipment (scheduled)`
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS Late_Shipment_Rate
FROM supply_chain_clean_data
GROUP BY
    `Shipping Mode`,
    `Category Name`
HAVING COUNT(*) >= 100
ORDER BY Late_Shipment_Rate DESC
LIMIT 15;
-- Step 56: Average shipping delay by mode and category

SELECT
    `Shipping Mode`,
    `Category Name`,
    COUNT(*) AS Total_Orders,
    ROUND(
        AVG(
            `Days for shipping (real)` -
            `Days for shipment (scheduled)`
        ), 2
    ) AS Avg_Shipping_Delay,
    SUM(
        CASE
            WHEN `Days for shipping (real)` >
                 `Days for shipment (scheduled)`
            THEN 1 ELSE 0
        END
    ) AS Late_Orders
FROM supply_chain_clean_data
GROUP BY
    `Shipping Mode`,
    `Category Name`
HAVING COUNT(*) >= 100
ORDER BY Avg_Shipping_Delay DESC
LIMIT 15;

-- Step 57: Profitability by shipping mode and category
SELECT
    `Shipping Mode`,
    `Category Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Shipping Mode`,
    `Category Name`
HAVING COUNT(*) >= 100
ORDER BY Profit_Margin ASC
LIMIT 15;

-- Step 58: Highest profit margins by shipping mode and category
SELECT
    `Shipping Mode`,
    `Category Name`,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,
    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin
FROM supply_chain_clean_data
GROUP BY
    `Shipping Mode`,
    `Category Name`
HAVING COUNT(*) >= 100
ORDER BY Profit_Margin DESC
LIMIT 15;

-- Step 59: Order value and profitability analysis
SELECT
    CASE
        WHEN `Sales` < 100 THEN 'Low Value'
        WHEN `Sales` < 250 THEN 'Medium Value'
        ELSE 'High Value'
    END AS Order_Value_Band,

    COUNT(*) AS Total_Orders,
    ROUND(SUM(`Sales`), 2) AS Total_Sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS Total_Profit,

    ROUND(
        SUM(`Order Profit Per Order`) /
        NULLIF(SUM(`Sales`), 0) * 100, 2
    ) AS Profit_Margin

FROM supply_chain_clean_data
GROUP BY Order_Value_Band
ORDER BY Total_Sales DESC;

-- Step 60: Shipping performance by order value
SELECT
    `Order Value Band`,
    `Shipping Performance`,
    COUNT(*) AS Total_Orders,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY `Order Value Band`
        ), 2
    ) AS Performance_Percentage

FROM supply_chain_clean_data

GROUP BY
    `Order Value Band`,
    `Shipping Performance`

ORDER BY
    `Order Value Band`,
    Total_Orders DESC;