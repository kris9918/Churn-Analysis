--How many distinct customers have churned and also have dependents?
SELECT 
	COUNT(DISTINCT(customerID))
FROM 
	dbo.Cleaned_df
WHERE 
	Churn = 1 AND Dependents = 1;

----How many customers have a monthly charge between $50 and $100 and have a tenure greater than 24 months?
SELECT 
	COUNT([customerID])
FROM 
	dbo.Cleaned_df
WHERE 
	[MonthlyCharges] BETWEEN 50 AND 100 AND [tenure] > 24;

----How many customers have an Electronic or Mailed Check payment method and have a contract type of One year?
SELECT 
	COUNT([customerID])
FROM 
	dbo.Cleaned_df
WHERE 
	[PaymentMethod] IN ('Electronic check' , 'Mailed check') AND [Contract] = 'One year';

----How many customers have a tenure not between 6 and 18 months and monthly charges greater than $80?
SELECT
	[customerID], [tenure], [MonthlyCharges]
FROM 
	dbo.Cleaned_df
WHERE 
	([tenure] NOT BETWEEN 6 AND 18) AND ([MonthlyCharges] > 80);

----What is the gender distribution of customers?
SELECT 
	[gender], COUNT([customerID]) AS #
FROM 
	dbo.Cleaned_df
GROUP BY 
	[gender];

----How many customers have churned and a monthly charge greater than the average monthly charge of all customers?
DECLARE 
	@avg_monthly_charge FLOAT;
SET 
	@avg_monthly_charge = (
		SELECT AVG(MonthlyCharges)
		FROM dbo.Cleaned_df);
SELECT 
	[customerID],  [MonthlyCharges], @avg_monthly_charge AS AverageMonthlyCharge
FROM 
	dbo.Cleaned_df
WHERE 
	(Churn = 1) AND (MonthlyCharges > @avg_monthly_charge);

--How many customer have churned and group them into differenet categories based on tenure.
SELECT
	CASE
		WHEN [tenure] < 12 THEN 'New Customer'
		WHEN [tenure] BETWEEN 13 AND  48 THEN 'Old Customer'
		ELSE  'Loyal Customer'
	END AS 'Type of Customer',
	[customerID], [tenure], [Churn]
FROM 
	dbo.Cleaned_df
WHERE 
	[Churn] = 1;

--What is the average tenure and monthly charge of churned customers based on gender?
SELECT 
	[gender], AVG([MonthlyCharges]) AS Average_Monthly_Charge, AVG([tenure]) AS Average_Tenure
FROM 
	dbo.Cleaned_df
WHERE 
	[Churn] = 1
GROUP BY 
	[gender];

--How many customers have churned and have a tenure greater than the average tenure of customers with a monthly charge between $50 and $100?
WITH AvgChargCust AS(
	SELECT
		AVG([tenure]) AS AvgTenure
	FROM
		dbo.Cleaned_df
	WHERE 
		[MonthlyCharges] BETWEEN 50 AND 100
)
SELECT
	COUNT([customerID])
FROM 
	dbo.Cleaned_df, AvgChargCust
WHERE
	([tenure] > AvgTenure) AND ([Churn] = 1);

--How many customers have churned who have a contract type of monthly, and their monthly charges are in the top 10% of all customers?
WITH Top10Charge AS(
	SELECT 
		TOP 10 PERCENT [MonthlyCharges] AS Top10
	FROM 
		dbo.Cleaned_df
	ORDER BY
		[MonthlyCharges] DESC
)
SELECT 
	COUNT([customerID])
FROM
	dbo.Cleaned_df, Top10Charge
WHERE
	([Churn] = 1) AND ([Contract] ='Month-to-month') AND ([MonthlyCharges] = Top10)