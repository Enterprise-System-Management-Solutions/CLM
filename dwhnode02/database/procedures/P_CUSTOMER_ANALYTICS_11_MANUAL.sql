--
-- P_CUSTOMER_ANALYTICS_11_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_11_MANUAL (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY           VARCHAR2(4);
    VDATE               DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    --------------------------------LD_SMS_REV-------------------------------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(M,16) */ M.MSISDN,SUM(LD_SMS_REV)AS LD_SMS_REV
    FROM
    (SELECT /*+ PARALLEL(A,16) */ C.MSISDN MSISDN, COALESCE (D.SMS_RECURRING_REVENUE, 0) + COALESCE (E.SMS_REVENUE, 0) AS LD_SMS_REV
    FROM
    (SELECT /*+ PARALLEL(A,16) */ SERVICE_NUMBER AS MSISDN FROM SUBSCRIPTION_DIM )C
    LEFT OUTER JOIN
    (SELECT /*+ PARALLEL(A,16) */ R375_CHARGINGPARTYNUMBER,SUM(R41_DEBIT_AMOUNT) SMS_RECURRING_REVENUE FROM L3_RECURRING A
    WHERE R377_CYCLEBEGINTIME_KEY  = VDATE_KEY
    AND R385_OFFERINGID IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='SMS')
    GROUP BY R375_CHARGINGPARTYNUMBER)D ON C.MSISDN = D.R375_CHARGINGPARTYNUMBER  
    LEFT OUTER JOIN
    (SELECT /*+ PARALLEL(A,16) */ S22_PRI_IDENTITY,SUM(S41_DEBIT_AMOUNT) SMS_REVENUE FROM L3_SMS A
    WHERE S387_CHARGINGTIME_KEY  = VDATE_KEY
    AND S378_SERVICEFLOW='1'
    GROUP BY S22_PRI_IDENTITY )E ON C.MSISDN = E.S22_PRI_IDENTITY
    )M
    GROUP BY MSISDN)B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_SMS_REV=B.LD_SMS_REV;
    COMMIT;
END;
/
