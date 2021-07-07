--
-- P_CUSTOMER_ANALYTICS_07  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_07 IS
BEGIN
    -------------------------LD_DATA_REV------------------------------------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(M,16) */ M.MSISDN,SUM(LD_DATA_REV)as LD_DATA_REV
    FROM
    (SELECT /*+ PARALLEL(A,16) */ C.MSISDN AS MSISDN,
    COALESCE (B.DATA_REVENUE, 0)  + COALESCE (D.RECURRING_DATA_REVENUE, 0) AS LD_DATA_REV
    FROM
    (SELECT /*+ PARALLEL(A,16) */ SERVICE_NUMBER AS MSISDN FROM SUBSCRIPTION_DIM )C
    LEFT OUTER JOIN
    (SELECT /*+ PARALLEL(A,16) */ A.G372_CALLINGPARTYNUMBER, SUM(G41_DEBIT_AMOUNT) DATA_REVENUE FROM L3_DATA A
    WHERE G383_CHARGINGTIME_KEY  = (SELECT DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
    GROUP BY A.G372_CALLINGPARTYNUMBER )B ON C.MSISDN = B.G372_CALLINGPARTYNUMBER
    LEFT OUTER JOIN
    (SELECT /*+ PARALLEL(A,16) */ R375_CHARGINGPARTYNUMBER,SUM(R41_DEBIT_AMOUNT) RECURRING_DATA_REVENUE FROM L3_RECURRING A
    WHERE R377_CYCLEBEGINTIME_KEY  = (SELECT DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
    AND R385_OFFERINGID IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='Data')
    GROUP BY R375_CHARGINGPARTYNUMBER)D ON C.MSISDN = D.R375_CHARGINGPARTYNUMBER  
    )M
    GROUP BY  M.MSISDN)B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_DATA_REV=B.LD_DATA_REV;
    COMMIT;
END;
/

