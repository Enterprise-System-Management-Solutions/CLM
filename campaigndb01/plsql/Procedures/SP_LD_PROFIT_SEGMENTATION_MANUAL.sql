--
-- SP_LD_PROFIT_SEGMENTATION_MANUAL  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_CAMPAIGN_USER01.SP_LD_PROFIT_SEGMENTATION_MANUAL (P_DATE VARCHAR2)  IS
VVAT NUMBER(4,2);
IOC  NUMBER(4,2);
BTRC_SOF NUMBER(4,2);
DVAT NUMBER (4,2);
VDATE_KEY VARCHAR2(4);
MIN_PROFIT NUMBER;
MAX_PROFIT NUMBER;

BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(TO_DATE(P_DATE,'RRRRMMDD'));

SELECT VALUE INTO VVAT
FROM PROFIT_CALCULATION
WHERE ID=2;

SELECT VALUE INTO IOC
FROM PROFIT_CALCULATION
WHERE ID=3;

SELECT SUM(VALUE) INTO BTRC_SOF
FROM PROFIT_CALCULATION
WHERE ID IN ('4','5');


SELECT VALUE INTO DVAT
FROM PROFIT_CALCULATION
WHERE ID=6;

-----------------------------------------------------------------------

INSERT INTO LD_PROFIT_SEGMENTATION(DATE_KEY,MSISDN, PROFIT_SEGMENTATION)
SELECT VDATE_KEY,MSISDN,PREFERRED
FROM 
(
SELECT VDATE_KEY,MSISDN,PROFIT,
CASE
WHEN NVL(PROFIT,0) <0
THEN 0
WHEN NVL(PROFIT,0) >0
THEN  NVL(PROFIT,0)
END PREFERRED

FROM
    (SELECT VDATE_KEY,F.MSISDN,SUM(F.PROFIT)AS PROFIT
    FROM
        (SELECT V.MSISDN,V.PROFIT
        FROM
            (SELECT A.MSISDN,(A.BASE_REVENUE-(A.BASE_REVENUE*BTRC_SOF/100)) AS PROFIT
            FROM
                (SELECT MSISDN, (NVL(VOICE_REVENUE,0)-(NVL(VOICE_REVENUE,0)*VVAT/100))-(IOC*NVL(DURATION,0)) AS BASE_REVENUE
                from
                    (select MSISDN,sum(VOICE_REVENUE) as VOICE_REVENUE,sum(DURATION)as DURATION
                    FROM CLM_VOICE_REV@CAMPAING_TO_DWH05
                    WHERE DATE_KEY=VDATE_KEY
                    group by MSISDN
                    )
                )A
            )V
        UNION ALL
        SELECT D.MSISDN, D.PROFIT
        FROM
            (SELECT MSISDN, (NVL(DATA_REVENUE,0)-(NVL(DATA_REVENUE,0)*DVAT/100)) AS PROFIT
            from
                (select MSISDN,sum(DATA_REVENUE)as DATA_REVENUE
                FROM CLM_DATA_REV@CAMPAING_TO_DWH05
                WHERE DATE_KEY=VDATE_KEY
                group by MSISDN
                )
            )D
        )F
GROUP BY F.MSISDN
)
);
COMMIT;

    BEGIN

        SELECT MIN(NVL(PROFIT_SEGMENTATION,0)) INTO MIN_PROFIT
        FROM LD_PROFIT_SEGMENTATION
        WHERE DATE_KEY = VDATE_KEY;

        SELECT MAX(NVL(PROFIT_SEGMENTATION,0)) INTO MAX_PROFIT
        FROM LD_PROFIT_SEGMENTATION
        WHERE DATE_KEY = VDATE_KEY;



        MERGE INTO LD_PROFIT_SEGMENTATION A
        USING (SELECT MSISDN, TO_NUMBER(TO_CHAR(SUM(NPROFIT),'9999.99')) AS NPROFIT 
        FROM
        (SELECT MSISDN,(NVL(PROFIT_SEGMENTATION,0)-NVL(MIN_PROFIT,0))/(NVL(MAX_PROFIT,0)-NVL(MIN_PROFIT,0)) AS NPROFIT
                FROM LD_PROFIT_SEGMENTATION
                WHERE DATE_KEY = VDATE_KEY)
                GROUP BY MSISDN) V 
        ON (A.MSISDN = V.MSISDN) 
        WHEN MATCHED THEN
        UPDATE SET A.NORMAL_VAL=V.NPROFIT;
        COMMIT;
    END;

END;
/

