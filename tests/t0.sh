#!/bin/bash

cd "$(dirname "$0")" > /dev/null 2>&1

source t.rc

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

exit_ok
