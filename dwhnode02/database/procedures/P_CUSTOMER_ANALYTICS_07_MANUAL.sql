--
-- P_CUSTOMER_ANALYTICS_07_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_07_MANUAL (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY           VARCHAR2(4);
    VDATE               DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    -------------------------LD_DATA_REV------------------------------------------------
/* Formatted on 10/19/2020 2:59:24 PM (QP5 v5.256.13226.35538) */
MERGE INTO CUSTOMER_ANALYTICS_LD A
     USING (  SELECT MSISDN, SUM (LD_DATA_REV) AS LD_DATA_REV
                FROM (SELECT /*+ PARALLEL(A,16) */
                            C.MSISDN AS MSISDN,
                               COALESCE (B.DATA_REVENUE, 0)
                             + COALESCE (D.RECURRING_DATA_REVENUE, 0)
                                AS LD_DATA_REV
                        FROM (SELECT /*+ PARALLEL(A,16) */
                                     SERVICE_NUMBER AS MSISDN
                                FROM SUBSCRIPTION_DIM) C
                             LEFT OUTER JOIN
                             (  SELECT /*+ PARALLEL(A,16) */
                                      A.G372_CALLINGPARTYNUMBER,
                                       SUM (G41_DEBIT_AMOUNT) DATA_REVENUE
                                  FROM L3_DATA A
                                 WHERE G383_CHARGINGTIME_KEY = VDATE_KEY
                              GROUP BY A.G372_CALLINGPARTYNUMBER) B
                                ON C.MSISDN = B.G372_CALLINGPARTYNUMBER
                             LEFT OUTER JOIN
                             (  SELECT /*+ PARALLEL(A,16) */
                                      R375_CHARGINGPARTYNUMBER,
                                       SUM (R41_DEBIT_AMOUNT)
                                          RECURRING_DATA_REVENUE
                                  FROM L3_RECURRING A
                                 WHERE     R377_CYCLEBEGINTIME_KEY = VDATE_KEY
                                       AND R385_OFFERINGID IN (SELECT OFFERING_ID
                                                                 FROM OFFER_DIM
                                                                WHERE OFFER_TYPE =
                                                                         'Data')
                              GROUP BY R375_CHARGINGPARTYNUMBER) D
                                ON C.MSISDN = D.R375_CHARGINGPARTYNUMBER)
            GROUP BY MSISDN) B
        ON (A.MSISDN = B.MSISDN)
WHEN MATCHED
THEN
   UPDATE SET A.LD_DATA_REV = B.LD_DATA_REV;

COMMIT;
END;
/

