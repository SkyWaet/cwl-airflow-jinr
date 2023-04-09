#!/bin/bash

echo "Set parameters from the environment variables or apply defaults"
: ${POSTGRES_USER:=airflow}
: ${POSTGRES_PASSWORD:=airflow}
: ${POSTGRES_DATABASE:=airflow}


echo "Wait until required database and tables are ready"

until PGPASSWORD=${POSTGRES_PASSWORD} psql --host=postgres --dbname=${POSTGRES_DATABASE} --username=${POSTGRES_USER}  -c "select * from dag_run"
do
    echo "Sleep 1 sec"
    sleep 1;
done

echo "Start cwl-airflow api"
cwl-airflow api "$@"