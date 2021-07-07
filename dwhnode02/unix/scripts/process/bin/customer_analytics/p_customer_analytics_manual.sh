PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

export TMP=/tmp
export TMPDIR=$TMP

export ORACLE_HOSTNAME=dwhnode02
export ORACLE_UNQNAME=dwhdb02
export ORACLE_BASE=/data01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1
export ORA_INVENTORY=/data01/app/oraInventory
export ORACLE_SID=dwhdb02
export DATA_DIR=/data01/oradata

export PATH=/usr/sbin:/usr/local/bin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

dt="$1"

sqlplus  -s <<EOF
dwh_user/dwh_user_123
SET echo off
SET head off
SET feedback off
REM "WHENEVER SQLERROR EXIT SQL.SQLCODE"
EXECUTE P_CUSTOMER_ANALYTICS_01_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_02_MANUAL($dt);
--EXECUTE P_CUSTOMER_ANALYTICS_03;
EXECUTE P_CUSTOMER_ANALYTICS_04_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_05_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_06_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_07_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_08_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_09_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_10_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_11_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_12_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_13_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_14_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_15_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_16_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_17_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_18_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_19_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_20_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_21_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_22_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS_23_MANUAL($dt);
EXECUTE P_CUSTOMER_ANALYTICS@DWH05TODWH_CAMPAIGN_USER01;
EXIT
EOF

echo "Processed Completed"

