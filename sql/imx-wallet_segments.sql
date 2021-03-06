/***
Author: GSB Labs
Date written: 2022-01-25
Objective: classify IMX wallets
***/


SELECT SEGMENT,
	CASE
		WHEN SEGMENT = 'plankton' THEN 1
	  WHEN SEGMENT = 'shrimp' THEN 2
	  WHEN SEGMENT = 'seahorse' THEN 3
	  WHEN SEGMENT = 'oyster' THEN 4
	  WHEN SEGMENT = 'starfish' THEN 5
	  WHEN SEGMENT = 'jellyfish' THEN 6
	  WHEN SEGMENT = 'crab' THEN 7
		WHEN SEGMENT = 'lobster' THEN 8
		WHEN SEGMENT = 'octopus' THEN 9
		WHEN SEGMENT = 'dolphin' THEN 10
		WHEN SEGMENT = 'shark' THEN 11
		WHEN SEGMENT = 'whale' THEN 12
	END RANKINGS,
	COUNT(*) AS COUNT,
	ROUND(SUM(AMOUNT), 3) AS AMOUNT,
	ROUND(100 * (SUM(AMOUNT) / 2e9), 3) AS PERCENT_TOTAL

FROM
	(SELECT C.ADDRESS,
			C.NAME,
			C.AMOUNT,
			CASE
				WHEN AMOUNT > 0 AND AMOUNT < 1 THEN 'plankton'
				WHEN AMOUNT >= 1 AND AMOUNT < 10 THEN 'shrimp'
				WHEN AMOUNT >= 10 AND AMOUNT < 100 THEN 'seahorse'
				WHEN AMOUNT >= 100 AND AMOUNT < 500 THEN 'oyster'
				WHEN AMOUNT >= 500 AND AMOUNT < 1000 THEN 'starfish'
				WHEN AMOUNT >= 1000 AND AMOUNT < 5000 THEN 'jellyfish'
				WHEN AMOUNT >= 5000 AND AMOUNT < 10000 THEN 'crab'
				WHEN AMOUNT >= 10000 AND AMOUNT < 50000 THEN 'lobster'
				WHEN AMOUNT >= 50000 AND AMOUNT < 100000 THEN 'octopus'
				WHEN AMOUNT >= 100000 AND AMOUNT < 500000 THEN 'dolphin'
				WHEN AMOUNT >= 50000 AND AMOUNT < 1E6 THEN 'shark'
				WHEN AMOUNT >= 1E6 THEN 'whale'
			END SEGMENT
		FROM
			(SELECT X.ADDRESS,
					N.NAME,
					SUM(X.VALUE) AS AMOUNT
				FROM
					(

-- Destination address amount
SELECT T1.TO AS ADDRESS,
							SUM(T1.VALUE / 1e18) AS VALUE
						FROM IMMUTABLE_X."IMXToken_evt_Transfer" T1
						GROUP BY 1
						UNION

-- Source address amount
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
							(SELECT ADDRESS,
									MAX(UPDATED_AT) AS UPDATED_AT
								FROM LABELS."labels"
								GROUP BY 1) Z ON L.ADDRESS = Z.ADDRESS
						AND L.UPDATED_AT = Z.UPDATED_AT) N ON N.ADDRESS = X.ADDRESS
				GROUP BY 1,
					2
				HAVING SUM(X.VALUE) > 0) C) FINAL
GROUP BY 1,2
ORDER BY 2

;
