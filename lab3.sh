#!/bin/bash -eu

#zad1

./fakaping.sh 2>&1 | grep -i "permission denied" | sort -u | tee denied.log
./fakaping.sh 2>&1 | sort -u | tee all.log


#zad2
grep "/denied" access_log

grep -Eo "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access_log | sort -u | head -n 10

#zad3
sed -i '/Help docs:/d' groovies/*


#zad4

cut -d',' -f6 yolo.csv | grep -E "^[0-9]\.[0-9]\.[0-9]{1,3}\.[0-9]{1,3}" 1>&2
