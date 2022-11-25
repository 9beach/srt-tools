#!/bin/bash

# Temporary working directory
tmpdir=$(mktemp -d)
n=0

function assert_ok {
	cmd=$(echo $1 | sed -e 's:\.\./::g' -e 's:/var[^ ]*/:\$tmpdir/:g' -e 's:/tmp[^ ]*/:\$tmpdir/:g')
	(( ${#cmd} > 71 )) && cmd="${cmd:0:68}..."
	eval "$1"
	if [ $? -eq 0 ]; then
		(( n++ ))
		echo "# ok:" $cmd
	else
		echo "# not ok:" $cmd
		rm -rf $tmpdir
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

function quit {
	rm -rf $tmpdir
	exit 0
}

cd "$(dirname "$0")" > /dev/null 2>&1

echo \# check SRTTIDY
assert_ok "../srttidy -f 'cc=10' < s01-utf8.srt | diff - s01-utf8-f.out"
assert_ok "../srttidy -f 'cc=10' -m '10,0.1' < s01-utf8.srt 2> >(diff - s01-utf8-fm.err >&2) > /dev/null"
assert_ok "../srttidy -f 'cc=10' -m '10,0.1' < s01-utf8.srt 2> /dev/null | diff - s01-utf8-fm.out"

assert_ok "../srttidy -f 'cc>26 and lc=2' -m 5,0.1 < s02-utf8.srt 2> /dev/null | diff - s02-utf8-fm.out"
assert_ok "../srttidy -f 'cc>26 and lc=2' -m 5,0.1 < s02-utf8.srt 2> >(diff - s02-utf8-fm.err >&2) > /dev/null"

assert_ok "../srttidy -d 'lee.*ta' < s03-ascii.srt | diff - s03-ascii-d.out"
assert_ok "../srttidy -d 'lee.*ta' < s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -r -d 'lee.*ta' < s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii-bom-cr.srt 2> /dev/null | diff - s03-ascii-bom-cr-m.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii.srt 2> /dev/null | diff - s03-ascii-m.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii.srt 2> >(diff - s03-ascii-m.err >&2) > /dev/null"
assert_ok "../srttidy -m 2,0.1 < s03-ascii-bom-cr.srt 2> >(diff - s03-ascii-bom-cr-m.err >&2) > /dev/null"

echo
echo \# check SMI2SRT
for i in s01*.smi; do 
	assert_ok "../smi2srt < $i | diff - s01-utf8.srt"
done

cp s01-*.smi $tmpdir
assert_ok "../smi2srt $tmpdir/s01-*smi 2> /dev/null"
assert_ok "[ '$(ls $tmpdir/s01-*smi | wc -l)' -eq '$(ls $tmpdir/s01-*srt | wc -l)' ]"

for i in $tmpdir/s01*.srt; do
	assert_ok "diff $i s01-utf8.srt > /dev/null"
done 

for i in s02*.smi; do 
	assert_ok "../smi2srt < $i | diff - s02-utf8.srt"
done

cp s02-*.smi $tmpdir
assert_ok "../smi2srt $tmpdir/s02-*smi 2> /dev/null"
assert_ok '[ "$(ls $tmpdir/s02*smi | wc -l)" -eq "$(ls $tmpdir/s02*srt | wc -l)" ]'
for i in $tmpdir/s02*.srt; do
	assert_ok "diff $i s02-utf8.srt > /dev/null"
done 

echo
echo \# check TEST FIXTURES
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
assert_ok "! diff s03-ascii-bom-cr-m.out s03-ascii-m.out > /dev/null"
assert_ok "rm_bom_cr < s03-ascii-bom-cr-m.out | diff - s03-ascii-m.out"
assert_ok "! diff s03-ascii-bom-cr.srt s03-ascii.srt > /dev/null"
assert_ok "rm_bom_cr < s03-ascii-bom-cr.srt | diff - s03-ascii.srt"
assert_ok "diff s03-ascii-m.err s03-ascii-bom-cr-m.err"

echo 
echo \# all $n cases DONE

quit
