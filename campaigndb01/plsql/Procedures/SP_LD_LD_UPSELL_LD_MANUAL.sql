--
-- SP_LD_LD_UPSELL_LD_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_CAMPAIGN_USER01.SP_LD_LD_UPSELL_LD_MANUAL (P_DATE VARCHAR2)  IS
VDATE_KEY VARCHAR2(4);
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(TO_DATE(P_DATE,'RRRRMMDD'));


INSERT INTO LD_UPSELL_LD
SELECT MSISDN, PREFERRED,VDATE_KEY
FROM 
(SELECT MSISDN,VOICE,SMS,DATA,
CASE
WHEN VOICE <= SMS AND VOICE <= DATA 
THEN 1
WHEN SMS <= VOICE AND SMS <= DATA 
THEN 2
WHEN DATA <= VOICE AND DATA <= SMS 
THEN 3

END PREFERRED

FROM 
(SELECT /*+PARALLEL(Q,15)*/MSISDN,SUM(NVL(VOICE_REVENUE,0))VOICE,SUM(NVL(SMS_REVENUE,0))SMS,SUM(NVL(DATA_REVENUE,0))DATA
FROM 
(
(SELECT /*+PARALLEL(P,15)*/MSISDN,SUM(VOICE_REVENUE)AS VOICE_REVENUE, NULL AS SMS_REVENUE, NULL AS DATA_REVENUE
FROM CLM_VOICE_REV@CAMPAING_TO_DWH05 P
WHERE DATE_KEY=VDATE_KEY
GROUP BY MSISDN)
UNION ALL 
(SELECT /*+PARALLEL(P,15)*/ MSISDN,NULL AS VOICE_REVENUE,SUM(SMS_REVENUE)AS SMS_REVENUE, NULL AS DATA_REVENUE
FROM CLM_SMS_REV@CAMPAING_TO_DWH05 P
WHERE DATE_KEY=VDATE_KEY
GROUP BY MSISDN)
UNION ALL
(SELECT /*+PARALLEL(P,15)*/ MSISDN,NULL AS VOICE_REVENUE,NULL AS SMS_REVENUE,SUM(DATA_REVENUE)AS DATA_REVENUE
FROM CLM_DATA_REV@CAMPAING_TO_DWH05 P
WHERE DATE_KEY=VDATE_KEY
GROUP BY MSISDN) 
)Q
GROUP BY MSISDN
)
);
COMMIT;
END;
/
