--
-- P_CUSTOMER_ANALYTICS_09  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_09 IS
BEGIN
    -----------------------------------LD_VOICE_REV---------------------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(SELECT /*+ PARALLEL(M,16) */M.MSISDN,SUM(LD_VOICE_REV)AS LD_VOICE_REV
    FROM
    (SELECT /*+ PARALLEL(A,16) */
          C.MSISDN AS MSISDN,
             COALESCE (A.VOICE_REVENUE, 0)
           + COALESCE (D.VOICE_RECURRING_REVENUE, 0)
              AS LD_VOICE_REV
      FROM (SELECT /*+ PARALLEL(A,16) */
                  SERVICE_NUMBER AS MSISDN FROM SUBSCRIPTION_DIM) C
           LEFT OUTER JOIN
           (  SELECT /*+ PARALLEL(A,16) */
                    A.V372_CALLINGPARTYNUMBER,
                     SUM (A.V41_DEBIT_AMOUNT) VOICE_REVENUE
                FROM L3_VOICE A
               WHERE     V387_CHARGINGTIME_KEY =
                            (SELECT DATE_KEY
                               FROM DATE_DIM
                              WHERE TRUNC (DATE_VALUE) = TRUNC (SYSDATE - 1))
                     AND V378_SERVICEFLOW = 1
            GROUP BY A.V372_CALLINGPARTYNUMBER) A
              ON C.MSISDN = A.V372_CALLINGPARTYNUMBER
           LEFT OUTER JOIN
           (  SELECT /*+ PARALLEL(A,16) */
                    R375_CHARGINGPARTYNUMBER,
                     SUM (R41_DEBIT_AMOUNT) VOICE_RECURRING_REVENUE
                FROM L3_RECURRING A
               WHERE     R377_CYCLEBEGINTIME_KEY =
                            (SELECT DATE_KEY
                               FROM DATE_DIM
                              WHERE TRUNC (DATE_VALUE) = TRUNC (SYSDATE - 1))
                     AND R385_OFFERINGID IN (SELECT OFFERING_ID
                                               FROM OFFER_DIM
                                              WHERE OFFER_TYPE = 'Voice')
            GROUP BY R375_CHARGINGPARTYNUMBER) D
            ON C.MSISDN = D.R375_CHARGINGPARTYNUMBER
    )M
    group by M.MSISDN)B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_VOICE_REV=B.LD_VOICE_REV;
    COMMIT;
END;
/

