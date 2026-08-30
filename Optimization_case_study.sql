SQL:
 CASE STUDY: OPTIMIZING AN INEFFICIENT RETAIL QUERY FOR THE CLOUD
 OBJECTIVE: Eliminate a full table scan, make the query SARGable, 
            and reduce CPU usage on the cloud instance.


---------------------------------------------------------------------------
 THE PROBLEM: THE SLOW QUERY (Non-SARGable)
 Why it's bad: Wrapping the [OrderDate] column inside the YEAR() function 
 forces SQL Server to perform a full Clustered Index Scan. It evaluates 
 every row in the table, ignoring any existing indexes on OrderDate.
---------------------------------------------------------------------------
SELECT 
    CustomerID, 
    COUNT(OrderID) AS TotalOrders, 
    SUM(TotalAmount) AS TotalSpent
FROM Orders
WHERE YEAR(OrderDate) = 2026 -- BAD PRACTICE: Index cannot be used effectively
GROUP BY CustomerID
HAVING SUM(TotalAmount) > 100;

---------------------------------------------------------------------------
 THE SOLUTION: THE OPTIMIZED QUERY (SARGable)
 Why it's good: By using an explicit date range with >= and < operators, 
 the query engine can perform a highly efficient Index Seek directly 
 on the OrderDate index boundary.
---------------------------------------------------------------------------
SELECT 
    CustomerID, 
    COUNT(OrderID) AS TotalOrders, 
    SUM(TotalAmount) AS TotalSpent
FROM Orders
WHERE OrderDate >= '2026-01-01' AND OrderDate < '2027-01-01' -- OPTIMIZED Boundary
GROUP BY CustomerID
HAVING SUM(TotalAmount) > 100;

---------------------------------------------------------------------------
 SUPPORTING INFRASTRUCTURE: INDEX OPTIMIZATION
 To make the optimized query run in milliseconds, we deploy a composite, 
 non-clustered index that includes our filter condition and covers our data.
---------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate_Include_CustomerSpent
ON Orders (OrderDate)
INCLUDE (CustomerID, TotalAmount, OrderID);
