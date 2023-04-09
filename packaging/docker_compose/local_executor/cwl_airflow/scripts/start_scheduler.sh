#!/bin/bash

echo "Set parameters from the environment variables or apply defaults"
: ${POSTGRES_USER:=airflow}
: ${POSTGRES_PASSWORD:=airflow}
: ${POSTGRES_DATABASE:=airflow}
: ${PROCESS_REPORT_URL:=""}

echo "Wait until required database is ready"
until PGPASSWORD=${POSTGRES_PASSWORD} psql --host=postgres --dbname=${POSTGRES_DATABASE} --username=${POSTGRES_USER}  -c "select * from dag_run"
do
    echo "Sleep 1 sec"
    sleep 1;
done

echo "Run initial configuration for CWL-Airflow"
cwl-airflow init --upgrade

if [ ! -z "${PROCESS_REPORT_URL}" ]; then
    echo "Create process_report connection"
    airflow connections delete process_report
    airflow connections add process_report --conn-uri ${PROCESS_REPORT_URL}
fi

echo "Start airflow scheduler"
airflow scheduler "$@"
