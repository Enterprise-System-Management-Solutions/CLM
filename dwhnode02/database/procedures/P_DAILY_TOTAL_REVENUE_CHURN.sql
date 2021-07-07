--
-- P_DAILY_TOTAL_REVENUE_CHURN  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_DAILY_TOTAL_REVENUE_CHURN (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY       NUMBER;
    VNUMBER         VARCHAR2(64);
    VREVENUE        NUMBER(18,6);    
    VDATE           DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    
INSERT INTO DAILY_TOTAL_REVENUE_CHURN

SELECT C.MSISDIN_NO,COALESCE (A.VOICE_REVENUE, 0)
    + COALESCE (B.DATA_REVENUE, 0)  + COALESCE (D.VAS_REVENUE, 0) + COALESCE (E.SMS_REVENUE, 0),VDATE_KEY
 FROM
     (SELECT MSISDIN_NO FROM ACTIVEBASE )C
     LEFT OUTER JOIN
    (SELECT A.V372_CALLINGPARTYNUMBER, SUM(A.V41_DEBIT_AMOUNT) VOICE_REVENUE FROM L3_VOICE A
    WHERE V387_CHARGINGTIME_KEY =VDATE_KEY
    GROUP BY A.V372_CALLINGPARTYNUMBER) A ON   C.MSISDIN_NO = A.V372_CALLINGPARTYNUMBER 
    LEFT OUTER JOIN
    (SELECT A.G372_CALLINGPARTYNUMBER, SUM(G41_DEBIT_AMOUNT) DATA_REVENUE FROM L3_DATA A
    WHERE G383_CHARGINGTIME_KEY =VDATE_KEY
    GROUP BY A.G372_CALLINGPARTYNUMBER )B ON C.MSISDIN_NO = B.G372_CALLINGPARTYNUMBER
    LEFT OUTER JOIN
    (SELECT R375_CHARGINGPARTYNUMBER,SUM(R41_DEBIT_AMOUNT) VAS_REVENUE FROM L3_RECURRING
    WHERE R377_CYCLEBEGINTIME_KEY =VDATE_KEY
    GROUP BY R375_CHARGINGPARTYNUMBER)D ON C.MSISDIN_NO = D.R375_CHARGINGPARTYNUMBER    
     LEFT OUTER JOIN
    (SELECT S22_PRI_IDENTITY,SUM(S41_DEBIT_AMOUNT) SMS_REVENUE FROM L3_SMS
    WHERE S387_CHARGINGTIME_KEY =VDATE_KEY
    GROUP BY S22_PRI_IDENTITY )E ON C.MSISDIN_NO = E.S22_PRI_IDENTITY;  
    COMMIT;
END;
/

