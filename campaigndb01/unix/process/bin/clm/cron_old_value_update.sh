##	Auther	: Tareq
##	Purpose : update value to clv,crosssell,upsale,profite segmen,usegs segment and customer models
## 	Date 	: 2021-06-09


PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
export ORACLE_SID=campaigndb01
export ORACLE_BASE=/data01/oracle/app/oracle
export ORACLE_HOME=/data01/oracle/app/oracle/product/12.2.0/dbhome_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$ORACLE_HOME/bin

dt=$1

lock=/data02/scripts/process/bin/lock/old_value_lock/manual_value_update_${dt}  export lock

if [ -f $lock ] ; then
exit 2

else
touch $lock

manual_value_update()
{
sqlplus  -s <<EOF
dwh_campaign_user01/dwh_campaign_user01
SET echo off
SET head off
SET feedback off
REM "WHENEVER SQLERROR EXIT SQL.SQLCODE"
EXECUTE SP_LD_CLV_LD_MANUAL($1);
EXECUTE SP_LD_CROSSSELL_LD_MANUAL($1);
EXECUTE SP_LD_LD_UPSELL_LD_MANUAL($1);
EXECUTE SP_LD_PROFIT_SEGMENTATION_MANUAL($1);
EXECUTE SP_LD_USEGS_SEGMENTATION_MANUAL($1);
EXECUTE SP_CUSTOMER_MODELS_UPDATE_MANUAL($1);
EXIT
EOF
}

manual_value_update $dt

fi




