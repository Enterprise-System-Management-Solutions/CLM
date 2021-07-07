dt=$(date --date=' 2 days ago' '+%Y%m%d')

cd /data02/scripts/process/bin/file_export/
./clm_export_manual.sh $dt
sleep 2
sshpass -p "root335" ssh root@192.168.61.246 sh -x /data02/scripts/process/bin/churn/churn_base_manual.sh $dt
sleep 2
cd /data02/scripts/process/bin/file_registration/
./churn_base_reg.sh
sleep 2
cd /data02/scripts/process/bin/loading_l1/
./load_customer_models_and_churn_value_manual.sh $dt
sleep 2
cd /data02/scripts/process/bin/clm/
#./sp_customer_models_update_manual.sh $dt
./cron_old_value_update.sh $dt
echo 'processed completed'
