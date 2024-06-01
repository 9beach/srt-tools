#!/bin/bash

cd "$(dirname "$0")" > /dev/null 2>&1

source t.rc

echo \# check SRTMEGE
assert_ok "../srtmerge s05.utf8.arg1 s05.utf8.arg2 | diff s05.utf8.merged -"
assert_ok "../srtmerge s05.utf8.arg1 s05.utf8.arg2.alt | diff s05.utf8.merged -"
