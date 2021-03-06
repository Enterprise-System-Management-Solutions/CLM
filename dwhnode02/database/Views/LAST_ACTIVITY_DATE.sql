--
-- LAST_ACTIVITY_DATE  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.LAST_ACTIVITY_DATE
(MSISDIN, DATE_VALUE)
BEQUEATH DEFINER
AS 
SELECT MSISDIN,DATE_VALUE FROM
DATE_DIM,
(
SELECT MSISDIN_NO MSISDIN, LAST_ACTIVITY_DATE_KEY AS LAST_ACTIVITY_DATE
FROM ACTIVEBASE INNER JOIN DATE_DIM ON DATE_KEY = LAST_ACTIVITY_DATE_KEY
WHERE  DATE_VALUE  BETWEEN TO_DATE ('2020/01/13', 'yyyy/mm/dd')
AND TO_DATE ('2020/02/01', 'yyyy/mm/dd')
GROUP BY MSISDIN_NO, LAST_ACTIVITY_DATE_KEY)
WHERE DATE_KEY=LAST_ACTIVITY_DATE;


