#!/bin/bash

cd "$(dirname "$0")" > /dev/null 2>&1

set -e

for i in t?.sh; do
	./$i
	echo
done
