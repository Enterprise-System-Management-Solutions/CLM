--
-- P_CUSTOMER_ANALYTICS_12  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_12 IS
BEGIN

    ----------------------------------------------LD_VAS_REV--------------------
    MERGE INTO CUSTOMER_ANALYTICS_LD A
    USING(select C.MSISDN,sum(C.LD_VAS_REV) as LD_VAS_REV from 
(SELECT /*+ PARALLEL(E,16) */ R375_CHARGINGPARTYNUMBER AS MSISDN,SUM(R41_DEBIT_AMOUNT) AS LD_VAS_REV
    FROM L3_RECURRING E
    WHERE R377_CYCLEBEGINTIME_KEY = (SELECT   DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
    and R385_OFFERINGID=(select offering_id from offer_dim where offer_type='MCN')
    GROUP BY R375_CHARGINGPARTYNUMBER
union
    select /*+ PARALLEL (D,16) */ CO372_CALLINGPARTYNUMBER as MSISDN, sum(CO41_DEBIT_AMOUNT) as LD_VAS_REV
    from l3_content D
    WHERE CO402_STARTTIMEOFBILLCYL_KEY = (SELECT   DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
    GROUP BY CO372_CALLINGPARTYNUMBER) C
    group by C.MSISDN)B   
    ON (A.MSISDN = B.MSISDN) 
    WHEN MATCHED THEN
    UPDATE SET A.LD_VAS_REV=B.LD_VAS_REV;
    COMMIT;
END;
/

