#!/bin/sh

set -e

host='127.0.0.1'
user='amirmnoohi'
pass='11041104'
version='0.37.50.15'

mysql_path=$(which mysql)
mysql_dir_path=$(dirname $mysql_path)

log() {
  echo
  echo "\e[37;42m$1\e[0m"
}
cd /tmp/dbt2-$version
log 'Loading the data into the database...'
scripts/mysql/mysql_load_db.sh \
  --path /tmp/dbt2/data \
  --local \
  --mysql-path "$mysql_path" \
  --host "$host" \
  --user "$user" \
  --password "$pass"

log 'Loading the stored procedures...'
scripts/mysql/mysql_load_sp.sh \
  --client-path "$mysql_dir_path" \
  --sp-path storedproc/mysql \
  --host "$host" \
  --user "$user" \
  --password "$pass"

log 'Running the benchmark...'
scripts/run_mysql.sh \
  --connections 20 \
  --time 300 \
  --warehouses 30 \
  --zero-delay \
  --host "$host" \
  --user "$user" \
  --password "$pass"