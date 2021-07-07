--
-- MONTHLY_CHURN  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.MONTHLY_CHURN
(MSISDN, CALL_MINUTES, MONTHLY_SMS_SEND_COUNT, MONTHLY_VAS_REVENUE, MONTHLY_RECHARGE_AMOUNT, 
 MONTHLY_RECHARGE_COUNT, MONTHLY_RECHARGE_REVENUE, MONTHLY_DATA_VOLUME_USED, MONTHLY_DATA_PACK_BY_COUNT, MONTHLY_PACK_BY_COUNT)
BEQUEATH DEFINER
AS 
SELECT
A.SERVICE_NUMBER AS MSISDN,
B.CALL_MINUTES,
c.MONTHLY_SMS_SEND_COUNT,
d.MONTHLY_VAS_REVENUE,
e.MONTHLY_RECHARGE_AMOUNT,
e.MONTHLY_RECHARGE_COUNT,
e.MONTHLY_RECHARGE_REVENUE,
f.MONTHLY_DATA_VOLUME_USED,
f.MONTHLY_DATA_PACK_BY_COUNT,
f.MONTHLY_PACK_BY_COUNT
FROM  SUBSCRIPTION_DIM A, VOICE_CHURN B, SMS_CHURN C,
RECURRING_CHURN D, VOU_CHURN E, DATA_CHURN F
WHERE A.SERVICE_NUMBER=B.MSISDN
AND A.SERVICE_NUMBER=C.MSISDN
AND A.SERVICE_NUMBER=D.MSISDN
AND A.SERVICE_NUMBER=E.MSISDN
AND A.SERVICE_NUMBER=F.MSISDN
GROUP BY SERVICE_NUMBER,SERVICE_NUMBER,CALL_MINUTES,MONTHLY_SMS_SEND_COUNT,MONTHLY_VAS_REVENUE,
MONTHLY_RECHARGE_AMOUNT,MONTHLY_RECHARGE_COUNT,MONTHLY_RECHARGE_REVENUE,
MONTHLY_DATA_VOLUME_USED,MONTHLY_DATA_PACK_BY_COUNT,MONTHLY_PACK_BY_COUNT;

