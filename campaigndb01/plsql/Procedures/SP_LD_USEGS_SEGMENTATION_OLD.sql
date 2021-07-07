--
-- SP_LD_USEGS_SEGMENTATION_OLD  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_CAMPAIGN_USER01.SP_LD_USEGS_SEGMENTATION_old IS
MIN_VUSEGS NUMBER;
MAX_VUSEGS NUMBER;
MIN_DUSEGS NUMBER;
MAX_DUSEGS NUMBER;

MIN_USEGS NUMBER;
MAX_USEGS NUMBER;

VDATE_KEY VARCHAR2(4);

BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1);
---------------------------------------------
SELECT MIN(NORMAL_VAL) INTO MIN_VUSEGS
FROM CLM_VOICE_USEGS@CAMPAING_TO_DWH05
WHERE DATE_KEY = VDATE_KEY;

SELECT MAX(NORMAL_VAL) INTO MAX_VUSEGS
FROM CLM_VOICE_USEGS@CAMPAING_TO_DWH05
WHERE DATE_KEY = VDATE_KEY;

SELECT MIN(NORMAL_VAL) INTO MIN_DUSEGS
FROM CLM_DATA_USEGS@CAMPAING_TO_DWH05
WHERE DATE_KEY = VDATE_KEY;

SELECT MAX(NORMAL_VAL) INTO MAX_DUSEGS
FROM CLM_DATA_USEGS@CAMPAING_TO_DWH05
WHERE DATE_KEY = VDATE_KEY;

MIN_USEGS := NVL(MIN_VUSEGS,0)+NVL(MIN_DUSEGS,0);

MAX_USEGS:= NVL(MAX_VUSEGS,0)+NVL(MAX_DUSEGS,0);


--??_????????????????????=(??-??_??????)/(??_??????-??_?????? )
--------------------------------------------
INSERT INTO LD_USEGS_SEGMENTATION(MSISDN, USEGS_SEGMENTATION, DATE_KEY)

SELECT MSISDN, TO_CHAR(USEGS_SEGMENTATION,'9999.99') USEGS_SEGMENTATION,VDATE_KEY
FROM
(
SELECT MSISDN,(nvl(TOTAL_USEGS,0)-NVL(MIN_USEGS,0))/(NVL(MAX_USEGS,0)-NVL(MIN_USEGS,0)) AS USEGS_SEGMENTATION
FROM
(
SELECT A.MSISDN,NVL(A.NORMAL_VAL,0)+NVL(B.NORMAL_VAL,0) AS TOTAL_USEGS
FROM CLM_VOICE_USEGS@CAMPAING_TO_DWH05 A FULL OUTER JOIN CLM_DATA_USEGS@CAMPAING_TO_DWH05 B
ON(A.MSISDN=B.MSISDN AND A.DATE_KEY=VDATE_KEY AND B.DATE_KEY=VDATE_KEY)
)
WHERE MSISDN IS NOT NULL
);
commit;


END;
/
