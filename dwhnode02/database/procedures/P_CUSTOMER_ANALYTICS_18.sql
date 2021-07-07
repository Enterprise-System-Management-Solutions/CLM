--
-- P_CUSTOMER_ANALYTICS_18  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_18 IS
BEGIN
    ----------------------------LD_VOC_DUR_AS_FST_PRT--------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(A,16) */ V372_CALLINGPARTYNUMBER AS MSISDN,SUM(V35_RATE_USAGE) AS LD_VOC_DUR_AS_FST_PRT
    FROM L3_VOICE A
    WHERE V387_CHARGINGTIME_KEY = (SELECT  DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
    AND V378_SERVICEFLOW=1
    GROUP BY V372_CALLINGPARTYNUMBER
    )B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_VOC_DUR_AS_FST_PRT=B.LD_VOC_DUR_AS_FST_PRT;
    COMMIT;
END;
/
