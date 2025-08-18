#!/bin/bash

echo "####################################################"
echo -e "######################\033[31mgrep\033[m##############################"

echo "####################################################"
echo -e "\033[35mShow only the lines in data.txt where the shell is /bin/bash\033[m"
grep "/bin/bash" data.txt

echo "####################################################"
echo -e "\033[35mFind lines in logs.txt that have the word ERROR (case-sensitive)\033[m"
grep "ERROR" logs.txt

echo "####################################################"
echo -e "\033[35mCount how many times the word INFO appears in logs.txt\033[m"
grep -ni "INFO" logs.txt | wc -l


echo "####################################################"
echo -e "\033[35mDisplay lines in data.txt that don_t contain /bin/bash\033[m"
grep -v "/bin/bash" data.txt

echo "####################################################"
echo -e "\033[35mExtract just the usernames (user1, user2, etc.) from data.txt using grep -o\033[m"
grep -o "^user[1-9]" data.txt

echo -e "\n\n"
echo "####################################################"
echo -e "#######################\033[31mawk\033[m##############################"
echo "####################################################"

echo -e "\033[35mPrint the first and last field of each line in data.txt (username and shell).\033[m"
awk 'BEGIN {FS = ":"} {printf "First feild: %s Last feild: %s\n", $1, $7}' data.txt


echo "####################################################"
echo -e "\033[35mShow usernames of people who use /bin/bash.\033[m"
awk -F":" '$7=="/bin/bash" {printf "Users who use %s are: %s\n", $7, $6}' data.txt

echo "####################################################"
echo -e "\033[35mPrint the 2nd and 3rd words from each line of logs.txt\033[m"


echo "####################################################"
echo -e "\033[35mFrom data.txt, calculate the sum of all UID numbers (3rd field).\033[m"



echo "####################################################"
echo -e "\033[35mPrint ERROR lines from logs.txt but only show the timestamp + message (strip out log level).
033[m"






