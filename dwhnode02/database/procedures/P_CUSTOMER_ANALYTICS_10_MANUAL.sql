--
-- P_CUSTOMER_ANALYTICS_10_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_10_MANUAL (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY           VARCHAR2(4);
    VDATE               DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    -----------------------------------LD_SMS_CNT-----------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(A,16) */ S22_PRI_IDENTITY AS MSISDN,COUNT(S22_PRI_IDENTITY) AS LD_SMS_CNT
    FROM L3_SMS
    WHERE S387_CHARGINGTIME_KEY = VDATE_KEY
    AND S378_SERVICEFLOW=1
    GROUP BY S22_PRI_IDENTITY)B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_SMS_CNT=B.LD_SMS_CNT;
    COMMIT;
END;
/

