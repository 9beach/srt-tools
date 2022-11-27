#!/bin/bash

cd "$(dirname "$0")" > /dev/null 2>&1

set -e

time -p for i in t?.sh; do
	./$i
	echo
done

echo
echo "# all" $(ls t?.sh | wc -l) "files DONE"
