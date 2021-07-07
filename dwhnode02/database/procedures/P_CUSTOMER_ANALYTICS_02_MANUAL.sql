--
-- P_CUSTOMER_ANALYTICS_02_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_CUSTOMER_ANALYTICS_02_MANUAL (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY           varchar2(4);
    VDATE               DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);

--EXECUTE IMMEDIATE 'TRUNCATE TABLE MSISDN_PRODUCT_WISE_LD DROP STORAGE';

EXECUTE IMMEDIATE 'TRUNCATE TABLE MSISDN_PRODUCT_WISE_LD DROP STORAGE';

INSERT INTO MSISDN_PRODUCT_WISE_LD
SELECT MSISDN, MAINOFFERINGID, CHARGINGTIME
  FROM (SELECT MSISDN,
               MAINOFFERINGID,
               CHARGINGTIME,
               ROW_NUMBER ()
                  OVER (PARTITION BY MSISDN ORDER BY CHARGINGTIME DESC)
                  ls
          FROM (  SELECT MSISDN,
                         MAINOFFERINGID,
                         MAX (CHARGINGTIME) AS CHARGINGTIME
                    FROM (SELECT /*+ PARALLEL(A,16) */
                                V372_CALLINGPARTYNUMBER AS MSISDN,
                                 V397_MAINOFFERINGID AS MAINOFFERINGID,
                                    V387_CHARGINGTIME_KEY
                                 || V387_CHARGINGTIME_HOUR
                                    AS CHARGINGTIME
                            FROM L3_VOICE A
                           WHERE     V387_CHARGINGTIME_KEY =VDATE_KEY
                                 AND V378_SERVICEFLOW = 1)
                GROUP BY MSISDN, MAINOFFERINGID
                UNION ALL
                  SELECT MSISDN,
                         MAINOFFERINGID,
                         MAX (CHARGINGTIME) AS CHARGINGTIME
                    FROM (SELECT /*+ PARALLEL(A,16) */
                                V373_CALLEDPARTYNUMBER AS MSISDN,
                                 V397_MAINOFFERINGID AS MAINOFFERINGID,
                                    V387_CHARGINGTIME_KEY
                                 || V387_CHARGINGTIME_HOUR
                                    AS CHARGINGTIME
                            FROM L3_VOICE A
                           WHERE     V387_CHARGINGTIME_KEY =VDATE_KEY
                                 AND V378_SERVICEFLOW = 2)
                GROUP BY MSISDN, MAINOFFERINGID
                UNION ALL
                  SELECT MSISDN,
                         MAINOFFERINGID,
                         MAX (CHARGINGTIME) AS CHARGINGTIME
                    FROM (SELECT /*+ PARALLEL(A,16) */
                                S22_PRI_IDENTITY AS MSISDN,
                                 S395_MAINOFFERINGID AS MAINOFFERINGID,
                                    S387_CHARGINGTIME_KEY
                                 || S387_CHARGINGTIME_HOUR
                                    AS CHARGINGTIME
                            FROM L3_SMS A
                           WHERE     S387_CHARGINGTIME_KEY =VDATE_KEY
                                 AND S378_SERVICEFLOW = 1)
                GROUP BY MSISDN, MAINOFFERINGID
                UNION ALL
                  SELECT MSISDN,
                         MAINOFFERINGID,
                         MAX (CHARGINGTIME) AS CHARGINGTIME
                    FROM (SELECT /*+ PARALLEL(A,16) */
                                G372_CALLINGPARTYNUMBER AS MSISDN,
                                 G401_MAINOFFERINGID AS MAINOFFERINGID,
                                    G383_CHARGINGTIME_KEY
                                 || G383_CHARGINGTIME_HOUR
                                    AS CHARGINGTIME
                            FROM L3_DATA A
                           WHERE G383_CHARGINGTIME_KEY =VDATE_KEY)
                GROUP BY MSISDN, MAINOFFERINGID)) where ls =1;
commit;

END;
/

