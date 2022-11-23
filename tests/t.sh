#!/bin/bash

# Temporary working directory
DIR=$(mktemp -d)

function assert_ok {
	cmd=$(echo $1 | sed -e 's:\.\./::g' -e 's:/var[^ ]*/::g' -e 's:/tmp[^ ]*/::g')
	(( ${#cmd} > 72 )) && cmd="${cmd:0:69}..."
	eval "$1"
	if [ $? -eq 0 ]; then
		echo "# ok:" $cmd
	else
		echo "# not ok:" $cmd
		rm -rf $DIR
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

echo \# Checks SRTTIDY
assert_ok "../srttidy -d 'lee.*ta' <s03-ascii.srt | diff - s03-ascii-d.out"
assert_ok "../srttidy -d 'lee.*ta' <s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -r -d 'lee.*ta' <s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -m 2,0.1 <s03-ascii-bom-cr.srt 2> /dev/null | diff - s03-ascii-bom-cr-m.out"
assert_ok "../srttidy -m 2,0.1 <s03-ascii.srt 2> /dev/null|diff - s03-ascii-m.out"

echo
echo \# Checks SMI2SRT
for i in s01*.smi; do 
	assert_ok "../smi2srt <\"$i\" | diff - s01-utf8.srt"
done

cp s01-*.smi $DIR
assert_ok "smi2srt $DIR/s01-*smi 2> /dev/null"

for i in $DIR/s01*.srt; do
	assert_ok "diff \"$i\" s01-utf8.srt > /dev/null"
done 

for i in s02*.smi; do 
	assert_ok "../smi2srt <\"$i\" | diff - s02-utf8.srt"
done

cp s02-*.smi $DIR
assert_ok "smi2srt $DIR/s02-*smi 2> /dev/null"

for i in $DIR/s02*.srt; do
	assert_ok "diff \"$i\" s02-utf8.srt > /dev/null"
done 

echo
echo \# Checks if test fixtures are valid
assert_ok "my_iconv cp949 s01-cp949.smi | diff - s01-utf8.smi"
assert_ok "my_iconv utf-16 s01-utf16.smi | diff - s01-utf8.smi"
assert_ok "my_iconv utf-16 s01-utf16.smi | diff - s01-utf8.smi"
assert_ok "my_iconv cp949 s01-cp949.srt | diff - s01-utf8.srt"
assert_ok "my_iconv utf-16 s01-utf16.srt | diff - s01-utf8.srt"
assert_ok "my_iconv utf-16 s01-utf16.srt | diff - s01-utf8.srt"
assert_ok "my_iconv cp949 s02-cp949.smi | diff - s02-utf8.smi"
assert_ok "my_iconv utf-16 s02-utf16.smi | diff - s02-utf8.smi"
assert_ok "my_iconv utf-16 s02-utf16.smi | diff - s02-utf8.smi"
assert_ok "my_iconv cp949 s02-cp949.srt | diff - s02-utf8.srt"
assert_ok "my_iconv utf-16 s02-utf16.srt | diff - s02-utf8.srt"
assert_ok "my_iconv utf-16 s02-utf16.srt | diff - s02-utf8.srt "
assert_ok "! diff s03-ascii-bom-cr-d.out s03-ascii-d.out > /dev/null"
assert_ok "rm_bom_cr < s03-ascii-bom-cr-d.out | diff - s03-ascii-d.out"
assert_ok "rm_bom_cr < s03-ascii-bom-cr-m.out | diff - s03-ascii-m.out"
assert_ok "! diff s03-ascii-bom-cr.srt s03-ascii.srt > /dev/null"
assert_ok "rm_bom_cr < s03-ascii-bom-cr.srt | diff - s03-ascii.srt"

rm -rf $DIR

echo 
echo \# All done
