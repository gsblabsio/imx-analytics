/***
Author: GSB Labs
Date written: 2022-01-25
Objective: top 50 IMX wallets

Methodology
1) SUM total destination amount
2) -SUM total source amount
3) UNION then SUM together
4) JOIN address labels based on last updated
***/


SELECT X.ADDRESS,
	N.NAME,
	ROUND(SUM(X.VALUE), 3) AS AMOUNT,
	ROUND(100 * (SUM(X.VALUE) / 2e9), 3) AS PERCENT_TOTAL -- 2 billion max supply

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
		GROUP BY 1) X
LEFT JOIN
	(SELECT L.ADDRESS,
			L.NAME,
			L.UPDATED_AT
		FROM LABELS."labels" L
		INNER JOIN
			(

-- Grab address label based on last updated
SELECT ADDRESS,
					MAX(UPDATED_AT) AS UPDATED_AT
				FROM LABELS."labels"
				GROUP BY 1) Z ON L.ADDRESS = Z.ADDRESS
		AND L.UPDATED_AT = Z.UPDATED_AT) N ON N.ADDRESS = X.ADDRESS
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 50

;
