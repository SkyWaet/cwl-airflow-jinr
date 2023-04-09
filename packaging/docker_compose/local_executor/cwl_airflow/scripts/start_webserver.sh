#!/bin/bash

echo "Set parameters from the environment variables or apply defaults"
: ${AIRFLOW_HOME:=airflow}
: ${POSTGRES_USER:=airflow}
: ${POSTGRES_PASSWORD:=airflow}
: ${POSTGRES_DATABASE:=airflow}

echo "Wait until required database and tables are ready"
until PGPASSWORD=${POSTGRES_PASSWORD} psql --host=postgres --dbname=${POSTGRES_DATABASE} --username=${POSTGRES_USER}  -c "select * from dag_run"
do
    echo "Sleep 1 sec"
    sleep 1;
done

echo "Wait until required files are ready"
until [ -e ${AIRFLOW_HOME}/webserver_config.py ]
do
    echo "Sleep 1 sec"
    sleep 1;
done

echo "Disable authentication in Airflow UI"
sed -i'.backup' -e 's/^# AUTH_ROLE_PUBLIC.*/AUTH_ROLE_PUBLIC = "Admin"/g' ${AIRFLOW_HOME}/webserver_config.py

echo "Start airflow webserver"
airflow webserver "$@"