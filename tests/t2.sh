#!/bin/bash

cd "$(dirname "$0")" > /dev/null 2>&1

source t.rc

echo \# check SRTTIDY
assert_ok "../srttidy -n < my.srt | diff - my-n.out"
assert_ok "../srttidy -n -d 'teeth' < my.srt | diff - my-nd.out"
assert_ok "../srttidy -n -g 'my' < my.srt | diff - my-ng.out"
assert_ok "../srttidy -c silver < my.srt | diff - my-c.out"
assert_ok "../srttidy -r < my-c.out | diff - my.srt"
assert_ok "../srttidy -n -1 < my.srt | diff - my-n1.out"
assert_ok "../srttidy -t -1 < my.srt | diff - my-t1.out"

assert_ok "../srttidy -t < s01-utf16.srt | diff - s01-utf16.txt"
assert_ok "../srttidy -t < s01-utf8.srt | diff - s01-utf8.txt"
assert_ok "../srttidy -t < s01-cp949.srt | diff - s01-cp949.txt"

assert_ok "../srttidy -s 32.1 < s01-utf16.srt | diff - s01-utf16-s.out"
assert_ok "../srttidy -l '00:00:19,145->00:00:22,189 01:39:17,715->02:39:18,390' < s01-utf16.srt | diff - s01-utf16-l.out"

assert_ok "../srttidy -f 'cc=10' < s01-utf8.srt | diff - s01-utf8-f.out"
assert_ok "../srttidy -m '10,0.1;cc=10' < s01-utf8.srt 2> >(diff - s01-utf8-fm.err >&2) > /dev/null"
assert_ok "../srttidy -m '10,0.1;cc=10' < s01-utf8.srt 2> /dev/null | diff - s01-utf8-fm.out"

assert_ok "../srttidy -m '5,0.1;cc>26 and lc=2' < s02-utf8.srt 2> /dev/null | diff - s02-utf8-fm.out"
assert_ok "../srttidy -m '5,0.1;cc>26 and lc=2' < s02-utf8.srt 2> >(diff - s02-utf8-fm.err >&2) > /dev/null"

assert_ok "../srttidy -b < s03-ascii-bom-cr.srt | diff - s03-ascii.srt"
assert_ok "../srttidy -d 'lee.*ta' < s03-ascii.srt | diff - s03-ascii-d.out"
assert_ok "../srttidy -d 'lee.*ta' < s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -r -d 'lee.*ta' < s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii-bom-cr.srt 2> /dev/null | diff - s03-ascii-bom-cr-m.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii.srt 2> /dev/null | diff - s03-ascii-m.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii.srt 2> >(diff - s03-ascii-m.err >&2) > /dev/null"
assert_ok "../srttidy -m 2,0.1 < s03-ascii-bom-cr.srt 2> >(diff - s03-ascii-bom-cr-m.err >&2) > /dev/null"

echo \# check srttidy ARGV
../srttidy -t -m '10,0.1;cc=10' < my.srt > /dev/null 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep 'Cannot use both.*-t' $tmpfile > /dev/null"
../srttidy -f 'cc=10' -m '10,0.1' < my.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep 'Cannot use both.*-m' $tmpfile > /dev/null"
assert_ok "! grep 'Cannot use both.*-t' $tmpfile > /dev/null"
../srttidy -m '10,.1' < my.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep '10,\.1.*not valid' $tmpfile > /dev/null"
../srttidy -f 'aa.8' < my.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep 'aa.8.*is not valid' $tmpfile > /dev/null"
../srttidy -f 'aa > .8' < my.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep 'aa > .8.*is not valid' $tmpfile > /dev/null"
../srttidy -m '4,6;aa > .8' < my.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep '4,6;aa > .8.*is not valid' $tmpfile > /dev/null"
../srttidy -m '4,6;(cc > 8))' < my.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep '4,6;(cc > 8)).*is not valid' $tmpfile > /dev/null"
assert_ok "../srttidy -m '4,6;(cc > 8) and (lc)' < my.srt > /dev/null 2> /dev/null"
assert_ok "! (../srttidy -m '4,6;(cc > 8) and lc)' < my.srt > /dev/null 2> /dev/null)"
rm -rf $tmpdir
mkdir $tmpdir
cp s02-*.srt $tmpdir
assert_ok "../srttidy $tmpdir/s02-*.srt 2> /dev/null"
assert_ok '[ "$(ls $tmpdir/s02-*.srt | grep -v 'tidy' | wc -l)" -eq "$(ls $tmpdir/s02-*-tidy.srt | wc -l)" ]'
for i in $tmpdir/s02-*-tidy.srt; do
        assert_ok "diff $i $tmpdir/s02-utf8-tidy.srt > /dev/null"
done

exit_ok
