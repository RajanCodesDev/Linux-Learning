#!/bin/bash

echo -e "\033[36m####################################################\033[m"
echo -e "######################\033[31mgrep\033[m##############################"

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mShow only the lines in data.txt where the shell is /bin/bash\033[m"
grep "/bin/bash" data.txt

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mFind lines in logs.txt that have the word ERROR (case-sensitive)\033[m"
grep "ERROR" logs.txt

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mCount how many times the word INFO appears in logs.txt\033[m"
grep -ni "INFO" logs.txt | wc -l
echo -e "\033[31m⚠️ grep -ni "INFO" logs.txt | wc -l → works, but -n (line number) is pointless here.
👉 Better:

grep -c "INFO" logs.txt\033[m"


echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mDisplay lines in data.txt that don_t contain /bin/bash\033[m"
grep -v "/bin/bash" data.txt

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mExtract just the usernames (user1, user2, etc.) from data.txt using grep -o\033[m"
grep -o "^user[1-9]" data.txt

########################################################################################

echo -e "\033[36m####################################################\033[m"
echo -e "#######################\033[31mawk\033[m##############################"

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mPrint the first and last field of each line in data.txt (username and shell).\033[m"
awk 'BEGIN {FS = ":"} {printf "First feild: %s Last feild: %s\n", $1, $7}' data.txt


echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mShow usernames of people who use /bin/bash.\033[m"
awk -F":" '$7=="/bin/bash" {printf "Users who use %s are: %s\n", $7, $6}' data.txt

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mPrint the 2nd and 3rd words from each line of logs.txt\033[m"
awk '{print $2, $3}' logs.txt

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mFrom data.txt, calculate the sum of all UID numbers (3rd field).\033[m"
awk 'BEGIN{FS = ":"} {sum+=$3} END {print sum}' data.txt

echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mPrint ERROR lines from logs.txt but only show the timestamp + message (strip out log level).\033[m"
awk '{msg=$0; sub($1 FS $2 FS $3 FS, "", msg); print $1, $2, msg}' logs.txt

########################################################################################

echo -e "\033[36m####################################################\033[m"
echo -e "######################\033[31msed\033[m##############################"
echo -e "\033[35mReplace /bin/bash with /bin/zsh in data.txt (print only, don’t overwrite yet).\033[m"
sed "s/\/bin\/bash/\/bin\/zsh/" data.txt
echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mRemove all lines in logs.txt containing INFO.\033[m"
sed '/INFO/d' logs.txt
echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mAdd the word [PROCESSED] at the end of every line in logs.txt.\033[m"
sed 's/$/PROCESSSED/' logs.txt
echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mDelete the first 2 lines of data.txt.\033[m"
sed '1,2d' data.txt
echo -e "\033[36m####################################################\033[m"
echo -e "\033[35mConvert all usernames (user1, user2, etc.) to uppercase.\033[m"
sed 's/user/USER/g' data.txt

########################################################################################

echo -e "\033[36m####################################################\033[m"
echo -e "###################\033[31mCombined Challenges\033[m#########################"



