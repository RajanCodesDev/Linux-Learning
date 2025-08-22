#!/bin/bash

echo -e "\033[35mFind all entries that returned a 500 status code\033[m"
awk '$9==500 { print $0 }' activity.log

echo -e "\033[35mHow many POST requests were made?\033[m"
awk '$6=="\"POST" {sum++} END { print sum }' activity.log

echo -e "\033[35mList all the unique IP addresses that accessed the server\033[m"
awk '{print $1}' activity.log | sort -u

echo -e "\033[35mShow all lines that accessed the /login page\033[m"
awk '$7=="/login" {print $0}' activity.log

echo -e "\033[35mFind all lines where the browser is Chrome\033[m"
grep -i "Chrome" activity.log

echo -e "\033[35mDisplay all log lines from IP address 192.168.1.10\033[m"
awk '$1=="192.168.1.10"' activity.log

echo -e "\033[35mHow many requests were served with a status code 200?\033[m"
awk '$9==200 {count++} END {print count}' activity.log

echo -e "\033[35mFind all lines that happened between 10:20:00 and 10:23:00\033[m"
grep "10:2[0-3]:[0-9][0-9]" activity.log

echo -e "\033[35mWhich pages returned a 404 error?\033[m"
awk '$9==404 {print $7}' activity.log | sort -u

echo -e "\033[35mFind all the entries that include the word ERROR (case-sensitive)\033[m"
grep "ERROR" activity.log
