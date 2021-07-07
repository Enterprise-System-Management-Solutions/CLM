--
-- P_CUSTOMER_ANALYTICS_14  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_14 IS
BEGIN

    ----------------------------LD_VOICE_PCK_BUY_CNT--------------------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(A,16) */ R375_CHARGINGPARTYNUMBER AS MSISDN,COUNT(R375_CHARGINGPARTYNUMBER) AS LD_VOICE_PCK_BUY_CNT
    FROM L3_RECURRING A, OFFER_DIM B
    WHERE R377_CYCLEBEGINTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
    AND A.R385_OFFERINGID=B.OFFERING_ID
    AND B.OFFER_TYPE='Voice'
    GROUP BY R375_CHARGINGPARTYNUMBER)B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_VOICE_PCK_BUY_CNT=B.LD_VOICE_PCK_BUY_CNT;
    COMMIT;
END;
/

