USE bi;

-- Question 1-  Answer
WITH MonthlySales AS 
(SELECT Branch,
DATE_FORMAT(STR_TO_DATE(Date_, '%d-%m-%Y'), '%Y-%m') AS month_,
SUM(Total_) AS total_sales
FROM walmartsales
GROUP BY Branch, month_),
SalesGrowth AS 
(SELECT Branch, month_, total_sales,
LAG(total_sales) OVER (PARTITION BY Branch ORDER BY month_) AS previous_month_sales
FROM MonthlySales)
SELECT Branch,
SUM(CASE WHEN previous_month_sales IS NOT NULL THEN 
(total_sales - previous_month_sales) / NULLIF(previous_month_sales, 0) 
ELSE 0 
END) AS total_growth_rate
FROM SalesGrowth
GROUP BY Branch
ORDER BY total_growth_rate DESC
Limit 1;

-- Question 2-  Answer


SELECT 
    Branch, Productline,
    SUM(gross_income - cogs) AS total_profit
FROM Walmartsales
GROUP BY Branch, Productline
ORDER BY Branch, total_profit DESC;

-- Question 3 Answer
WITH CustomerSpending AS 
(SELECT CustomerID, SUM(Total_) AS total_spending
FROM walmartsales
GROUP BY CustomerID),
AverageSpending AS 
(SELECT AVG(total_spending) AS avg_spending
FROM CustomerSpending)
SELECT cs.CustomerID, cs.total_spending,
CASE
WHEN cs.total_spending >= avg.avg_spending * 1.5 THEN 'High Spender'
WHEN cs.total_spending >= avg.avg_spending THEN 'Medium Spender'
ELSE 'Low Spender'
END AS spending_tier
FROM CustomerSpending cs
CROSS JOIN AverageSpending avg;


-- Question 4- Answer
WITH AverageSales AS
(SELECT Productline, AVG(Total_) AS AverageTotal,
STDDEV(Total_) AS StdDevTotal FROM walmartsales
GROUP BY Productline),
Anomalies AS 
(SELECT w.*,
CASE WHEN w.Total_ > (a.AverageTotal + 2 * a.StdDevTotal) THEN 'High'
WHEN w.Total_ < (a.AverageTotal - 2 * a.StdDevTotal) THEN 'Low'
ELSE 'Normal'
END AS AnomalyType
FROM walmartsales w
JOIN AverageSales a ON w.Productline = a.Productline)
SELECT * FROM Anomalies
WHERE AnomalyType != 'Normal';

-- Question 5 
WITH PaymentCounts AS 
(SELECT City, Payment, COUNT(*) AS PaymentCount
FROM walmartsales
GROUP BY City, Payment),
RankedPayments AS 
(SELECT City,Payment,PaymentCount,
ROW_NUMBER() OVER (PARTITION BY City ORDER BY PaymentCount DESC) AS Rank_
FROM PaymentCounts)
SELECT City, Payment AS MostPopularPayment, PaymentCount
FROM RankedPayments
WHERE Rank_ = 1;

-- Question 6
SELECT 
DATE_FORMAT(STR_TO_DATE(Date_, '%d-%m-%Y'), '%Y-%m') AS SalesMonth,
Gender, SUM(Total_) AS TotalSales
FROM walmartsales
GROUP BY SalesMonth, Gender
ORDER BY SalesMonth, Gender;

-- Question 7
SELECT Productline, Customertype, COUNT(*) AS PurchaseCount FROM walmartsales
GROUP BY Productline, Customertype
ORDER BY Productline, Customertype;

-- Question 8- Answer
SELECT a.CustomerID, a.Date_, a.Total_ AS PurchaseAmount, COUNT(b.InvoiceID) AS RepeatPurchases
FROM walmartsales a
JOIN 
walmartsales b ON a.CustomerID = b.CustomerID 
AND a.InvoiceID != b.InvoiceID 
AND DATEDIFF(STR_TO_DATE(b.Date_, '%d-%m-%Y'), STR_TO_DATE(a.Date_, '%d-%m-%Y')) <= 30
GROUP BY a.CustomerID, a.Date_, a.Total_
HAVING RepeatPurchases > 0
ORDER BY a.CustomerID, a.Date_;

-- Question 9- Answer
SELECT CustomerID, SUM(Total_) AS TotalRevenue
FROM walmartsales
GROUP BY CustomerID
ORDER BY TotalRevenue DESC
LIMIT 5;

-- Question 10- Answer
SELECT 
DAYNAME(STR_TO_DATE(Date_, '%d-%m-%Y')) AS DayOfWeek,
SUM(Total_) AS TotalSales
FROM walmartsales
GROUP BY DayOfWeek
ORDER BY TotalSales DESC;






























