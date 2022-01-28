/***
Author: GSB Labs
Date written: 2022-01-28
Objective: IMX circulating supply
***/


SELECT ADDRESS,
	VALUE,
	2E9 - value AS circulating_supply,
	ROUND(100 * (2E9 - value) / 2E9, 3) AS pct_total

FROM
	(

-- Destination amount
SELECT T1.TO AS ADDRESS,
			SUM(T1.VALUE / 1e18) AS VALUE
		FROM IMMUTABLE_X."IMXToken_evt_Transfer" T1
		GROUP BY 1
		UNION

-- Source amount
SELECT F1.FROM AS ADDRESS,
            -SUM(F1.VALUE / 1e18) AS VALUE
		FROM IMMUTABLE_X."IMXToken_evt_Transfer" F1
		GROUP BY 1) Z

WHERE ADDRESS = '\xe1d1ad55254b29b43035937894514d0adbac7aea' -- IMX address

;
