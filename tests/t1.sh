#!/bin/bash

cd "$(dirname "$0")" > /dev/null 2>&1

source t.rc

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

exit_ok
