--
-- P_CUSTOMER_ANALYTICS_17  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_17 IS
BEGIN

    ----------------------------LD_TOTAL_PCK_BUY_CNT--------------------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(A,16) */ R375_CHARGINGPARTYNUMBER AS MSISDN,COUNT(R375_CHARGINGPARTYNUMBER) AS LD_TOTAL_PCK_BUY_CNT
    FROM L3_RECURRING A
    WHERE R377_CYCLEBEGINTIME_KEY = (SELECT  DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
    GROUP BY R375_CHARGINGPARTYNUMBER)B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_TOTAL_PCK_BUY_CNT=B.LD_TOTAL_PCK_BUY_CNT;
    COMMIT;
END;
/

