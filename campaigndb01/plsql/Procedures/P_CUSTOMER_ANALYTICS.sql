--
-- P_CUSTOMER_ANALYTICS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_CAMPAIGN_USER01.P_CUSTOMER_ANALYTICS IS 
BEGIN
    INSERT INTO CUSTOMER_ANALYTICS(MSISDN, LOCATION_NAME,CONTRACT_TYPE, PRODUCT_NAME, FST_DAY_ON_NETWORK, LD_TOTAL_REV, LD_RECHARGE, LD_DATA_VOL, LD_DATA_REV, LD_VOICE_DURATION, LD_VOICE_REV, LD_SMS_CNT, LD_SMS_REV, LD_MMS_CNT, LD_MMS_REV, LD_VIDEO_CALL_DURATION, LD_VIDEO_CALL_REV, LD_VAS_REV, LD_DATA_PCK_BUY_CNT, LD_VOICE_PCK_BUY_CNT, LD_MIX_PCK_BUY_CNT, LD_VAS_BUY_CNT, LD_TOTAL_PCK_BUY_CNT, LD_VOC_DUR_AS_FST_PRT, LD_VOC_CNT_AS_FST_PRT, LD_VOC_DUR_AS_SCE_PRT, LD_VOC_CNT_AS_SCE_PRT, SNAPSHOT_DATE, PROCESSING_DATE, DELETED, DELETED_BY, DELETED_DATE)
    SELECT  MSISDN,
    LOCATION_NAME, 
    CONTRACT_TYPE, 
    PRODUCT_NAME, 
    TO_DATE(TO_CHAR(FST_DAY_ON_NETWORK,'MM/DD/YYYY'),'MM/DD/YYYY') AS FST_DAY_ON_NETWORK,
    NVL(LD_TOTAL_REV,0) AS LD_TOTAL_REV,
    NVL(LD_RECHARGE,0) AS LD_RECHARGE, 
    NVL(LD_DATA_VOL,0) AS LD_DATA_VOL, 
    NVL(LD_DATA_REV,0) AS LD_DATA_REV,
    NVL(LD_VOICE_DURATION,0) AS  LD_VOICE_DURATION,
    NVL(LD_VOICE_REV,0) AS LD_VOICE_REV,
    NVL(LD_SMS_CNT,0) AS LD_SMS_CNT,
    NVL(LD_SMS_REV,0) AS  LD_SMS_REV,
    NVL(LD_MMS_CNT,0) AS LD_MMS_CNT, 
    NVL(LD_MMS_REV,0) AS  LD_MMS_REV,
    NVL(LD_VIDEO_CALL_DURATION,0) AS  LD_VIDEO_CALL_DURATION,
    NVL(LD_VIDEO_CALL_REV,0) AS LD_VIDEO_CALL_REV,
    NVL(LD_VAS_REV,0) AS LD_VAS_REV,
    NVL(LD_DATA_PCK_BUY_CNT,0) AS LD_DATA_PCK_BUY_CNT, 
    NVL(LD_VOICE_PCK_BUY_CNT,0) AS LD_VOICE_PCK_BUY_CNT,
    NVL(LD_MIX_PCK_BUY_CNT,0) AS LD_MIX_PCK_BUY_CNT,
    NVL(LD_VAS_BUY_CNT,0) AS  LD_VAS_BUY_CNT,
    NVL(LD_TOTAL_PCK_BUY_CNT,0) AS LD_TOTAL_PCK_BUY_CNT,
    NVL(LD_VOC_DUR_AS_FST_PRT,0) AS  LD_VOC_DUR_AS_FST_PRT,
    NVL(LD_VOC_CNT_AS_FST_PRT,0) AS  LD_VOC_CNT_AS_FST_PRT,
    NVL(LD_VOC_DUR_AS_SCE_PRT,0) AS LD_VOC_DUR_AS_SCE_PRT,
    NVL(LD_VOC_CNT_AS_SCE_PRT,0) AS LD_VOC_CNT_AS_SCE_PRT,
    TO_DATE(TO_CHAR(SNAPSHOT_DATE,'MM/DD/YYYY'),'MM/DD/YYYY') AS SNAPSHOT_DATE,
    TO_DATE(TO_CHAR(PROCESSING_DATE,'MM/DD/YYYY'),'MM/DD/YYYY') AS PROCESSING_DATE, 
    NVL(DELETED,0) AS DELETED,  
    DELETED_BY, 
    DELETED_DATE
    FROM CUSTOMER_ANALYTICS_LD@CAMPAING_TO_DWH05
    WHERE LOCATION_NAME IS NOT NULL
    and PRODUCT_NAME IS NOT NULL;
COMMIT;
end;
/
