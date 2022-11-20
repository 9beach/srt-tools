#!/bin/sh

function my_iconv {
	iconv -f $1 -t utf-8 "$2"
}

function assert_ok {
	if [ $1 -eq 0 ]; then
		echo \# $2: succeeded
	else
		echo \# $2: failed
		rm -f $t1 $t2
		exit 1
	fi
}

t1=$(mktemp)
t2=$(mktemp)

# Checks if test fixtures are valid
my_iconv cp949 s01-cp949.smi > $t1
my_iconv utf-16 s01-utf16.smi > $t2

diff $t1 $t2 > /dev/null
assert_ok $? "check fixtures"

smi2srt <s01-cp949.smi | diff - s01-utf8.srt > /dev/null
assert_ok $? "smi2srt <01-cp949.smi"

srttidy -d 'Lo.*lee.*ta' <s02-western.srt | diff - s02-western-d.out
assert_ok $? "srttidy -d \"Lo.*lee.*ta\" <s02-western.srt"
