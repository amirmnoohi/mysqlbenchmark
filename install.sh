#!/bin/sh

mysql_path=$(which mysql)
mysql_dir_path=$(dirname $mysql_path)

log() {
  echo
  echo -e "\e[37;42m$1\e[0m"
}

# Clean up previous builds
rm -rf /tmp/dbt2

# Set up working directories
mkdir -p /tmp/dbt2/data

log 'Downloading...'
wget -q -O - http://downloads.mysql.com/source/dbt2-0.37.50.15.tar.gz | tar xvz -C /tmp/dbt2

# Go to the directory extracted
cd /tmp/dbt2/dbt2-0.37.50.15

# Fix a non-nullable parameter
search='ol_delivery_d timestamp NOT NULL'
replace='ol_delivery_d timestamp NULL'
sed -i "s/$search/$replace/g" scripts/mysql/mysql_load_db.sh

log 'Configuring...'
./configure --with-mysql

log 'Compiling...'
make

log 'Generating the data files...'
src/datagen -w 30 -d /tmp/dbt2/data --mysql

# Convert customer data to UTF-8 (utf8mb4 is the default in MySQL 8.0)
log 'Converting to UTF-8...'

for filename in `find /tmp/dbt2/data -type f -name *.data`; do
    echo $filename
    mv $filename $filename.bak
    iconv -f ISO-8859-1 -t UTF-8 $filename.bak -o $filename
    rm $filename.bak
done