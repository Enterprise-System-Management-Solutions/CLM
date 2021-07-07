--
-- P_CUSTOMER_ANALYTICS_05_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_05_MANUAL (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY           VARCHAR2(4);
    VDATE               DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    ------------------RECHARGE AMOUNT SUM ------------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(A,16) */ RE6_PRI_IDENTITY AS MSISDN, SUM(RE3_RECHARGE_AMT) AS RE3_RECHARGE_AMT
    FROM L3_RECHARGE
    WHERE RE30_ENTRY_DATE_KEY=VDATE_KEY
    GROUP BY RE6_PRI_IDENTITY
    )B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_RECHARGE=B.RE3_RECHARGE_AMT;
    COMMIT;
END;
/

