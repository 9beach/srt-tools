#!/bin/bash

cd "$(dirname "$0")" > /dev/null 2>&1

source t.rc

echo \# check argv SRTTIDY
../srttidy -t -m '10,0.1;cc=10' < s01-utf8.srt > /dev/null 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep 'Cannot use both.*-t' $tmpfile > /dev/null"
../srttidy -f 'cc=10' -m '10,0.1' < s01-utf8.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep 'Cannot use both.*-m' $tmpfile > /dev/null"
assert_ok "! grep 'Cannot use both.*-t' $tmpfile > /dev/null"
../srttidy -m '10,.1' < s01-utf8.srt 2> $tmpfile
assert_ok '[ $? -ne 0 ]'
assert_ok "grep '10,\.1.*not valid' $tmpfile > /dev/null"

echo \# check SRTTIDY
assert_ok "../srttidy -f 'cc=10' < s01-utf8.srt | diff - s01-utf8-f.out"
assert_ok "../srttidy -m '10,0.1;cc=10' < s01-utf8.srt 2> >(diff - s01-utf8-fm.err >&2) > /dev/null"
assert_ok "../srttidy -m '10,0.1;cc=10' < s01-utf8.srt 2> /dev/null | diff - s01-utf8-fm.out"

assert_ok "../srttidy -m '5,0.1;cc>26 and lc=2' < s02-utf8.srt 2> /dev/null | diff - s02-utf8-fm.out"
assert_ok "../srttidy -m '5,0.1;cc>26 and lc=2' < s02-utf8.srt 2> >(diff - s02-utf8-fm.err >&2) > /dev/null"

assert_ok "../srttidy -d 'lee.*ta' < s03-ascii.srt | diff - s03-ascii-d.out"
assert_ok "../srttidy -d 'lee.*ta' < s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -r -d 'lee.*ta' < s03-ascii-bom-cr.srt | diff - s03-ascii-bom-cr-d.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii-bom-cr.srt 2> /dev/null | diff - s03-ascii-bom-cr-m.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii.srt 2> /dev/null | diff - s03-ascii-m.out"
assert_ok "../srttidy -m 2,0.1 < s03-ascii.srt 2> >(diff - s03-ascii-m.err >&2) > /dev/null"
assert_ok "../srttidy -m 2,0.1 < s03-ascii-bom-cr.srt 2> >(diff - s03-ascii-bom-cr-m.err >&2) > /dev/null"

exit_ok
