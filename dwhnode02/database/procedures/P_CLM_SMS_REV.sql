--
-- P_CLM_SMS_REV  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CLM_SMS_REV (P_START_DATE VARCHAR2)  IS

BEGIN
INSERT INTO  CLM_SMS_REV
SELECT /* + PARALLEL(A,16)*/ (SELECT DATE_KEY FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=P_START_DATE),A.MSISDN,SUM(A.DEBIT_AMOUNT)
FROM
    (
    SELECT /* + PARALLEL(A,16)*/  S22_PRI_IDENTITY AS MSISDN,S41_DEBIT_AMOUNT AS DEBIT_AMOUNT
    FROM L3_SMS
    WHERE S387_CHARGINGTIME_KEY =(SELECT DATE_KEY FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=P_START_DATE)
    AND S378_SERVICEFLOW=1
    union all
    SELECT /*+PARALLEL(P,15)*/ R375_CHARGINGPARTYNUMBER AS MSISDN,R41_DEBIT_AMOUNT AS DEBIT_AMOUNT
    FROM L3_RECURRING P
    WHERE R377_CYCLEBEGINTIME_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=P_START_DATE)
    AND R385_OFFERINGID IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='SMS')
    ) A
GROUP BY A.MSISDN;
COMMIT;

END;
/

