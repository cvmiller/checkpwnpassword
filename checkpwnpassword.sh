#!/usr/bin/env bash

##################################################################################
#
#  Copyright (C) 2015-2018 Craig Miller
#
#  See the file "LICENSE" for information on usage and redistribution
#  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#  Distributed under GPLv2 License
#
##################################################################################


#
#	Script asks for password, then runs SHA1 hash, and checks it against haveibeenpwned
#		Password never leaves the machine, only first 5 digits of SHA1 hash are sent to haveibeenpwned
#
#	by Craig Miller		20 Dec 2021

#	
#	Assumptions:
#
#

function usage {
           echo "	$0 - check haveibeenpwned password database "
		   echo "	    for more info see:"
		   echo "	    https://haveibeenpwned.com/API/v3#SearchingPwnedPasswordsByRange"
	       echo "	"
	       echo "	e.g. $0 -p  <password> "
	       echo "	-d  debug"
	       echo "	"
	       echo " By Craig Miller - Version: $VERSION"
	       exit 1
           }

VERSION=0.95

# initialize some vars
HAVEIBEENPWNED_API="https://api.pwnedpasswords.com/range/"


DEBUG=0
PASSWORD=""

while getopts "?hdp:s" options; do
  case $options in
    p ) PASSWORD=$OPTARG
    	numopts=$(( numopts + 2));;
    d ) DEBUG=1
    	(( numopts++));;
    h ) usage;;
    \? ) usage	# show usage with flag and no value
         exit 1;;
    * ) usage		# show usage with unknown flag
    	 exit 1;;
  esac
done
# remove the options as cli arguments
shift $numopts


# check that there are no arguments left to process
if [ $# -ne 0 ]; then
	usage
	exit 1
fi

# detect if sha1 is prsent
cmd_detect=$(which sha1sum 2>/dev/null)
if [ $? -ne 0 ]; then
	# Oops, better stop
	echo "sha1sum NOT FOUND, please install, exiting..."
	usage
	exit 1
fi
sha1_cmd=$cmd_detect

# detect if curl is prsent
cmd_detect=$(which curl 2>/dev/null)
if [ $? -ne 0 ]; then
	# Oops, better stop
	echo "curl NOT FOUND, please install, exiting..."
	usage
	exit 1
fi
curl_cmd=$cmd_detect

# if password not on command line, then ask for it
if [ "$PASSWORD" == "" ]; then
	echo -n "Enter password: "
	stty -echo
	read -r PASSWORD
	echo
	stty echo
fi


# grab password 
test_pass=$PASSWORD

# create sha1 of Password
test_sha1=$(echo -n "$test_pass" | $sha1_cmd)

# trim tail spaces
test_sha1=${test_sha1:0:40}
# make upper case
test_sha1=${test_sha1^^}
if (( DEBUG == 1 )); then
	echo "SHA1=$test_sha1"
fi
test_sha1_tail=${test_sha1:5:35}
#echo "tail:$test_sha1_tail|"

# extract first 5 chars
test_sha5=${test_sha1:0:5}
if (( DEBUG == 1 )); then
	echo "SHA5=$test_sha5"
fi



# submit to API
result=$($curl_cmd $HAVEIBEENPWNED_API"$test_sha5" 2> /dev/null)
#if (( DEBUG == 1 )); then
#	echo "API Result=$result"
#fi

if (( DEBUG == 1 )); then
	sleep 1
	echo "password md5 hash:"
	echo "$test_sha1_tail"
	echo " look for similarities:"
	echo "$(echo "$result" | tr '\r' '\n' |  grep  "^${test_sha1_tail:0:2}")"
	echo "------"
	#exit
fi

# check our SHA1 to API result
check_sha_result=$(echo "$result" | grep  "$test_sha1_tail")
if [ $? -ne 0 ]; then
	echo "Password appears safe, unknown to HAVEIBEENPWNED_API"
else
	echo "Password matches HAVEIBEENPWNED_API" | grep --colour ".*"
	check_sha_result=$(echo "$result" | tr '\r' '\n' | grep "$test_sha1_tail" )
	result_hash=$(echo "$check_sha_result" | cut -d ':' -f 1 )
	result_amt=$(echo "$check_sha_result" | cut -d ':' -f 2 )
	echo "SHA1 Match: $test_sha5$result_hash, $result_amt times"

fi	


echo "pau"


