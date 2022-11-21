#!/bin/sh

function my_iconv {
	iconv -f $1 -t utf-8 "$2"
}

function assert_ok {
	if [ $1 -eq 0 ]; then
		echo \# succeeded: $2
	else
		echo \# failed: $2
		rm -f $t1 $t2
		exit 1
	fi
}

t1=$(mktemp)
t2=$(mktemp)

cd "$(dirname "$0")" > /dev/null 2>&1

# Checks if test fixtures are valid
my_iconv cp949 s01-cp949.smi > $t1
my_iconv utf-16 s01-utf16.smi > $t2

diff $t1 $t2 > /dev/null
assert_ok $? "check fixtures"

../smi2srt <s01-cp949.smi | diff - s01-utf8.srt > /dev/null
assert_ok $? "smi2srt <s01-cp949.smi"

../srttidy -d 'Lo.*lee.*ta' <s02-ascii.srt | diff - s02-ascii-d.out
assert_ok $? "srttidy -d 'Lo.*lee.*ta' <s02-ascii.srt"

../srttidy -d 'Lo.*lee.*ta' <s02-ascii-bom-crlf.srt | diff - s02-ascii-d.out
assert_ok $? "srttidy -d 'Lo.*lee.*ta' <s02-ascii-bom-crlf.srt"

../srttidy -d 'lita.*ligh' <s04-ascii.srt | diff - s04-ascii-d1.out
assert_ok $? "srttidy -d 'lita.*ligh' <s02-ascii-bom-crlf.srt"

../srttidy -d 'lita.*\nligh' <s04-ascii.srt | diff - s04-ascii-d2.out
assert_ok $? 'srttidy -d "lita.*\\nligh" <s04-ascii.srt'

assert_ok 0 all 
rm -f $t1 $t2
