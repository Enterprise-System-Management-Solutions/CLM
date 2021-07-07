#!/bin/bash
PATH='/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin'

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

export ORACLE_SID=campaigndb01
export ORACLE_UNQNAME=campaigndb01
export ORACLE_BASE=/data01/oracle/app/oracle
export ORACLE_HOME=/data01/oracle/app/oracle/product/12.2.0/dbhome_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib

export PATH=$PATH:$ORACLE_HOME/bin

dt=$1

#dt=`date -d yesterday  '+%Y%m%d'`
xdir=/data01/clm_export_dump/customer_analytics_dump.csv

C_CUSTOMER_ANALYTICS()
{
sqlplus  -s <<EOF
dwh_campaign_user01/dwh_campaign_user01
SET ECHO OFF
SET HEAD OFF
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET HEADSEP OFF
SET TERMOUT OFF
SET UNDERLINE OFF
SET LINESIZE 32000;
SET PAGESIZE 40000;
SET LONG 50000;
SPOOL $1
SELECT MSISDN||'|'||LD_TOTAL_REV||'|'||LD_RECHARGE||'|'||LD_DATA_VOL||'|'||LD_DATA_REV||'|'||LD_VOICE_DURATION||'|'||LD_VOICE_REV||'|'||LD_SMS_CNT||'|'||LD_SMS_REV||'|'||LD_MMS_CNT||'|'||LD_MMS_REV||'|'||LD_VIDEO_CALL_DURATION||'|'||LD_VIDEO_CALL_REV||'|'||LD_VAS_REV||'|'||LD_DATA_PCK_BUY_CNT||'|'||LD_VOICE_PCK_BUY_CNT||'|'||LD_MIX_PCK_BUY_CNT||'|'||LD_VAS_BUY_CNT||'|'||LD_TOTAL_PCK_BUY_CNT||'|'||LD_VOC_DUR_AS_FST_PRT||'|'||LD_VOC_CNT_AS_FST_PRT||'|'||LD_VOC_DUR_AS_SCE_PRT||'|'||LD_VOC_CNT_AS_SCE_PRT AS MY_QUERY
FROM CUSTOMER_ANALYTICS
WHERE TRUNC(SNAPSHOT_DATE)=to_date(TO_DATE($2,'RRRR/MM/DD'),'dd/mm/rrrr');
EXIT
EOF
}

C_CUSTOMER_ANALYTICS $xdir $dt

cd /data01/clm_export_dump/
cat hader.txt > h_customer_analytics_dump.csv
cat customer_analytics_dump.csv >> h_customer_analytics_dump.csv
sed -i '/^$/d' h_customer_analytics_dump.csv

rm -f customer_analytics_dump.csv
mv h_customer_analytics_dump.csv customer_analytics_dump.csv

#File Transfer to 246 for churn_base
sshpass -p "root335" scp customer_analytics_dump.csv root@192.168.61.246:/data02/churn_base

RESULT=$?
if [ $RESULT -eq 0 ]; then
  rm -f customer_analytics_dump.csv
else
  exit 2
fi

