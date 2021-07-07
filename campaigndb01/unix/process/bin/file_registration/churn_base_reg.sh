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

#DATE=$1
file='churn_output'
XFILE="${file}"
type='churn_base'
LIMIT=1
MINCOUNT=1
LDIR=/data02/churn_out

getFileList()
{

cd $LDIR
filecount=`ls $XFILE*.csv | wc -l`
if [ "$filecount" -eq "$MINCOUNT" ] ; then
        ls  $XFILE*.csv  | head -$LIMIT
fi

}
getFileList $XFILE


data_pre()
{
sqlplus  -s <<EOF
dwh_campaign_user01/dwh_campaign_user01
SET echo on
SET head off
SET feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE

INSERT INTO CHURN_LOG
(file_id,file_name,process_status,process_date,source,pre_count)
values(FILE_ID.nextval,'$1',30,SYSDATE,'$type',$2)
/
COMMIT
/
EXIT
EOF
}



lock=/data02/scripts/process/bin/lock/churn_base  export lock

if [ -f $lock ] ; then
exit 2

else
touch $lock

fileList=`getFileList`

for fil in $fileList
do
echo "moving from $LDIR  to $LDIR/process_dir for ${fil}"
##pre_count for every files
pc1=`cat $LDIR/$fil | wc -l`

mv $LDIR/$fil $LDIR/process_dir/$fil
v1=`echo ${fil}|sed s/.csv/\ /g|awk '{print $1}'`
data_pre $v1 $pc1
echo "File registration end for ${v1} `date`"

done
rm -f $lock
fi

