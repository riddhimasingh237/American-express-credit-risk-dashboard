--Q1 How many total customers are in the dataset?
select
count(distinct(customer_id))
from AmexCustomerData

--Q2 What is the average age, income, credit score, credit limit, and credit utilization of customers?
select
avg(age),
avg(net_yearly_income),
avg(credit_score),
avg(credit_limit),
avg(credit_limit_used)
from AmexCustomerData

--Q3 What is the customer distribution by gender?
select
gender,
count(customer_id) as total_customers
from AmexCustomerData
group by gender

--Q4 Which are the top 10 occupations with the highest number of customers?
select top 10
occupation_type as occupation,
count(customer_id) as total_customers
from AmexCustomerData
group by occupation_type 
order by total_customers desc

--Q5 Which occupations have the highest average yearly income?
select
avg(net_yearly_income) as income,
occupation_type
from AmexCustomerData
group by occupation_type
order by income desc

--Q6 How does average credit limit vary across income groups?
SELECT
    CASE
        WHEN net_yearly_income < 200000 THEN 'Low Income Group'
        WHEN net_yearly_income < 500000 THEN 'Lower Middle Income'
        WHEN net_yearly_income < 1000000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS income_group,

    COUNT(*) AS total_customers,
    AVG(credit_limit) AS average_credit_limit

FROM dbo.AmexCustomerData
GROUP BY
    CASE
        WHEN net_yearly_income < 200000 THEN 'Low Income Group'
        WHEN net_yearly_income < 500000 THEN 'Lower Middle Income'
        WHEN net_yearly_income < 1000000 THEN 'Middle Income'
        ELSE 'High Income'
    END;

--Q7 How are customers distributed across credit-score bands: Poor, Fair, Good, and Excellent?
SELECT
    CASE
        WHEN credit_score < 580 THEN 'Poor'
        WHEN credit_score < 670 THEN 'Fair'
        WHEN credit_score < 740 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_score_band,

    COUNT(*) AS total_customers

FROM dbo.AmexCustomerData

GROUP BY
    CASE
        WHEN credit_score < 580 THEN 'Poor'
        WHEN credit_score < 670 THEN 'Fair'
        WHEN credit_score < 740 THEN 'Good'
        ELSE 'Excellent'
    END

ORDER BY
    CASE
        WHEN
            CASE
                WHEN credit_score < 580 THEN 'Poor'
                WHEN credit_score < 670 THEN 'Fair'
                WHEN credit_score < 740 THEN 'Good'
                ELSE 'Excellent'
            END = 'Poor' THEN 1
        WHEN
            CASE
                WHEN credit_score < 580 THEN 'Poor'
                WHEN credit_score < 670 THEN 'Fair'
                WHEN credit_score < 740 THEN 'Good'
                ELSE 'Excellent'
            END = 'Fair' THEN 2
        WHEN
            CASE
                WHEN credit_score < 580 THEN 'Poor'
                WHEN credit_score < 670 THEN 'Fair'
                WHEN credit_score < 740 THEN 'Good'
                ELSE 'Excellent'
            END = 'Good' THEN 3
        ELSE 4
    END;


--Q8 What is the average credit utilization percentage for each credit-score band?
Alter table AmexCustomerData
Add credit_score_band [CHAR];


SELECT
    credit_band,
    ROUND(AVG(credit_limit_used), 2) AS avg_credit_utilization_percentage
FROM dbo.AmexCustomerData
GROUP BY credit_band
ORDER BY
    CASE credit_band
        WHEN 'Poor' THEN 1
        WHEN 'Fair' THEN 2
        WHEN 'Good' THEN 3
        WHEN 'Excellent' THEN 4
    END;


 --Q9  Do customers who own a car or house have different average income, credit score, or credit limit?
 SELECT
    owns_car,
    owns_house,
    COUNT(*) AS total_customers,
    ROUND(AVG(net_yearly_income), 2) AS avg_yearly_income,
    ROUND(AVG(credit_score), 2) AS avg_credit_score,
    ROUND(AVG(credit_limit), 2) AS avg_credit_limit
FROM dbo.AmexCustomerData
GROUP BY
    owns_car,
    owns_house
ORDER BY
    owns_car,
    owns_house;

--Q10 Which customers have the highest credit limits?
Select top 10
customer_id,
credit_limit
from AmexCustomerData
order by credit_limit desc

-- Q11 Which customers use the highest percentage of their credit limit?
select top 10
customer_id,
credit_limit,
credit_limit_used
from AmexCustomerData
order by credit_limit_used desc

-- Page 2: Default Risk & High-Risk Customer Monitoring

 --Q12 What is the overall default rate in the last six months?
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE 
            WHEN default_in_last_6months = 1 THEN 1 
            ELSE 0 
        END) AS defaulted_customers,
    ROUND(
        100.0 * SUM(CASE 
                        WHEN default_in_last_6months = 1 THEN 1 
                        ELSE 0 
                    END) / COUNT(*),
        2
    ) AS default_rate_percentage
FROM dbo.AmexCustomerData;

--Q13 Which occupation types have the highest default rate?

SELECT
OCCUPATION_TYPE,
COUNT(*) AS TOTAL_CUSTOMERS,
SUM(PREV_DEFAULTS),
ROUND(100*SUM(PREV_DEFAULTS)/COUNT(*),2) AS DEFAULT_RATE_PERCENTAGE
FROM AmexCustomerData
GROUP BY OCCUPATION_TYPE
HAVING COUNT(*) >= 50
ORDER BY default_rate_percentage DESC;

---Q14 How does default rate change across income groups?
SELECT
    income_group,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS default_rate_percentage
FROM dbo.AmexCustomerData
GROUP BY income_group
ORDER BY
    CASE income_group
        WHEN 'Low Income' THEN 1
        WHEN 'Lower Middle Income' THEN 2
        WHEN 'Middle Income' THEN 3
        WHEN 'High Income' THEN 4

--Default rate by credit-score band

SELECT
    credit_band,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS default_rate_percentage
FROM dbo.AmexCustomerData
GROUP BY credit_band
ORDER BY
    CASE credit_band
        WHEN 'Poor' THEN 1
        WHEN 'Fair' THEN 2
        WHEN 'Good' THEN 3
        WHEN 'Excellent' THEN 4
    END;
   
SELECT
    CASE
        WHEN prev_defaults > 0 THEN 'Previous Default'
        ELSE 'No Previous Default'
    END AS previous_default_status,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS recent_default_rate_percentage
FROM dbo.AmexCustomerData
GROUP BY
    CASE
        WHEN prev_defaults > 0 THEN 'Previous Default'
        ELSE 'No Previous Default'
    END;


SELECT
    utilization_band,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS default_rate_percentage
FROM dbo.AmexCustomerData
GROUP BY utilization_band
ORDER BY
    CASE utilization_band
        WHEN 'Low Utilization' THEN 1
        WHEN 'Medium Utilization' THEN 2
        WHEN 'High Utilization' THEN 3
    END;


    SELECT
    debt_to_income_band,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS default_rate_percentage
FROM dbo.AmexCustomerData
WHERE debt_to_income_band IS NOT NULL
GROUP BY debt_to_income_band
ORDER BY
    CASE debt_to_income_band
        WHEN 'Low DTI' THEN 1
        WHEN 'Medium DTI' THEN 2
        WHEN 'High DTI' THEN 3
    END;


    SELECT
    customer_id,
    occupation_type,
    net_yearly_income,
    credit_score,
    credit_limit,
    credit_limit_used,
    debt_to_income_ratio,
    prev_defaults,
    default_in_last_6months,
    risk_score,
    risk_segment
FROM dbo.AmexCustomerData
WHERE credit_limit_used >= 70
  AND credit_score < 650
ORDER BY risk_score DESC, credit_score ASC, credit_limit_used DESC;


SELECT
    customer_id,
    occupation_type,
    net_yearly_income,
    yearly_debt_payments,
    debt_to_income_ratio,
    prev_defaults,
    credit_score,
    credit_limit_used,
    risk_score,
    risk_segment
FROM dbo.AmexCustomerData
WHERE debt_to_income_ratio >= 40
  AND prev_defaults > 0
ORDER BY risk_score DESC, debt_to_income_ratio DESC;


SELECT
    occupation_type,
    income_group,
    credit_band,
    COUNT(*) AS total_customers,
    ROUND(AVG(risk_score), 2) AS average_risk_score,
    ROUND(
        100.0 * SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS default_rate_percentage
FROM dbo.AmexCustomerData
GROUP BY
    occupation_type,
    income_group,
    credit_band
HAVING COUNT(*) >= 20
ORDER BY average_risk_score DESC, default_rate_percentage DESC;


SELECT
    risk_segment,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM dbo.AmexCustomerData
GROUP BY risk_segment
ORDER BY
    CASE risk_segment
        WHEN 'Low Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'High Risk' THEN 3
    END;



SELECT
    COUNT(*) AS high_risk_customers,
    SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) AS defaulted_high_risk_customers,
    ROUND(
        100.0 * SUM(CASE WHEN default_in_last_6months = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS high_risk_default_rate_percentage
FROM dbo.AmexCustomerData
WHERE risk_segment = 'High Risk';


SELECT TOP 20
    customer_id,
    occupation_type,
    net_yearly_income,
    credit_score,
    credit_limit,
    credit_limit_used,
    debt_to_income_ratio,
    prev_defaults,
    default_in_last_6months,
    risk_score,
    risk_segment
FROM dbo.AmexCustomerData
ORDER BY
    risk_score DESC,
    credit_score ASC,
    credit_limit_used DESC;


    SELECT
    CASE
        WHEN default_in_last_6months = 1 THEN 'Defaulted'
        ELSE 'Non-Defaulted'
    END AS customer_status,
    COUNT(*) AS total_customers,
    ROUND(AVG(credit_score), 2) AS avg_credit_score,
    ROUND(AVG(credit_limit_used), 2) AS avg_credit_utilization,
    ROUND(AVG(debt_to_income_ratio), 2) AS avg_debt_to_income_ratio,
    ROUND(AVG(prev_defaults), 2) AS avg_previous_defaults,
    ROUND(AVG(net_yearly_income), 2) AS avg_income,
    ROUND(AVG(credit_limit), 2) AS avg_credit_limit
FROM dbo.AmexCustomerData
GROUP BY
    CASE
        WHEN default_in_last_6months = 1 THEN 'Defaulted'
        ELSE 'Non-Defaulted'
    END;








