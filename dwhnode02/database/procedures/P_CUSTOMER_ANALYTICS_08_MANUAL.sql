--
-- P_CUSTOMER_ANALYTICS_08_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_08_MANUAL (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY           VARCHAR2(4);
    VDATE               DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    ----------------------LD_VOICE_DURATION----------------------------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(A,16) */ V372_CALLINGPARTYNUMBER AS MSISDN,SUM(V35_RATE_USAGE) AS LD_VOICE_DURATION                
    FROM L3_VOICE
    WHERE V387_CHARGINGTIME_KEY = VDATE_KEY
    GROUP BY V372_CALLINGPARTYNUMBER
    )B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_VOICE_DURATION=B.LD_VOICE_DURATION;
    COMMIT;
END;
/

