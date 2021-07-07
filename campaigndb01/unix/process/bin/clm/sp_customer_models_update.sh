#Auther: Tareq
##Purpose : update value to customer_models_update table
## Date : 2020-10-15


PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
export ORACLE_SID=campaigndb01
export ORACLE_BASE=/data01/oracle/app/oracle
export ORACLE_HOME=/data01/oracle/app/oracle/product/12.2.0/dbhome_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$ORACLE_HOME/bin



sqlplus  -s <<EOF
dwh_campaign_user01/dwh_campaign_user01
SET echo off
SET head off
SET feedback off
REM "WHENEVER SQLERROR EXIT SQL.SQLCODE"
EXECUTE SP_CUSTOMER_MODELS_UPDATE;
EXIT
EOF

