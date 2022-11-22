#!/bin/sh

function assert_ok {
	if [ $1 -eq 0 ]; then
		echo \# ok: $2
	else
		echo \# not ok: $2
		rm -f $t1 $t2
		exit 1
	fi
}

function my_iconv {
	iconv -f $1 -t utf-8 "$2"
}

function rm_bom_cr {
	sed -e "1s/^$(printf '\357\273\277')//" -e "s/$(printf '\r')\$//" 
}

function chext {
        echo "$(echo "$1" | sed -e 's/\.[^\/\.]*$//').$2"
}

cd "$(dirname "$0")" > /dev/null 2>&1

../srttidy -d 'lee.*ta' <s03-ascii.srt | diff - s03-ascii-d.out
assert_ok $? "srttidy -d 'lee.*ta' <s03-ascii.srt"

../srttidy -d 'lee.*ta' <s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out
assert_ok $? "srttidy -d 'lee.*ta' <s03-ascii-bom-cr.srt"

# Checks if test fixtures are valid
my_iconv cp949 s01-cp949.smi | diff - s01-utf8.smi && \
	my_iconv utf-16 s01-utf16.smi | diff - s01-utf8.smi && \
	my_iconv utf-16 s01-utf16.smi | diff - s01-utf8.smi && \
	my_iconv cp949 s01-cp949.srt | diff - s01-utf8.srt && \
	my_iconv utf-16 s01-utf16.srt | diff - s01-utf8.srt && \
	my_iconv utf-16 s01-utf16.srt | diff - s01-utf8.srt && 
	my_iconv cp949 s02-cp949.smi | diff - s02-utf8.smi && \
	my_iconv utf-16 s02-utf16.smi | diff - s02-utf8.smi && \
	my_iconv utf-16 s02-utf16.smi | diff - s02-utf8.smi && \
	my_iconv cp949 s02-cp949.srt | diff - s02-utf8.srt && \
	my_iconv utf-16 s02-utf16.srt | diff - s02-utf8.srt && \
	my_iconv utf-16 s02-utf16.srt | diff - s02-utf8.srt  && \
	! diff s03-ascii-bom-cr-d.out s03-ascii-d.out > /dev/null && \
	rm_bom_cr < s03-ascii-bom-cr-d.out | diff - s03-ascii-d.out && \
	! diff s03-ascii-bom-cr.srt s03-ascii.srt > /dev/null && \
	rm_bom_cr < s03-ascii-bom-cr.srt | diff - s03-ascii.srt
assert_ok $? "check fixtures"

# SMI2SRT tests
for i in s01*.smi; do 
	../smi2srt <"$i" | diff - s01-utf8.srt
	assert_ok $? "smi2srt <$i"
done

DIR=$(mktemp -d)
cp s01*smi $DIR
smi2srt $DIR/*smi 2> /dev/null
assert_ok $? 'smi2srt s01*.smi'

for i in $DIR/*srt; do
	diff "$i" s01-utf8.srt > /dev/null
	assert_ok $? "diff $(basename $i) s01-utf8.srt"
done 

rm -rf $DIR

for i in s02*.smi; do 
	../smi2srt <"$i" | diff - s02-utf8.srt
	assert_ok $? "smi2srt <$i"
done

DIR=$(mktemp -d)
cp s02*smi $DIR
smi2srt $DIR/*smi 2> /dev/null
assert_ok $? 'smi2srt s02*.smi'

for i in $DIR/*srt; do
	diff "$i" s02-utf8.srt > /dev/null
	assert_ok $? "diff $(basename $i) s02-utf8.srt"
done 

rm -rf $DIR

assert_ok 0 all
