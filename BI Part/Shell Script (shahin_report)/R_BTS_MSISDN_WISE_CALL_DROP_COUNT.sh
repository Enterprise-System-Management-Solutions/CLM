PATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib;TH=$PATH:$HOME/.local/bin:$HOME/bin

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


partition=`sqlplus  -s <<EOF
dwh_user/dwh_user_123
SET echo off
SET head off
SET feedback off
REM "WHENEVER SQLERROR EXIT SQL.SQLCODE"
select 'date_key'||'_'||date_key from date_dim where trunc(date_value)=trunc(sysdate);
EXIT
EOF`



BTS_MSISDN_WISE_CALL_DROP_COUNT()
{
sqlplus  -s <<EOF
dwh_user/dwh_user_123
SET echo off
SET head off
SET feedback off
REM "WHENEVER SQLERROR EXIT SQL.SQLCODE"
alter table BTS_MSISDN_WISE_CALL_DROP_COUNT truncate partition $1;
EXECUTE R_BTS_MSISDN_WISE_CALL_DROP_COUNT;
EXIT
EOF
}
BTS_MSISDN_WISE_CALL_DROP_COUNT $partition
echo "$1"


