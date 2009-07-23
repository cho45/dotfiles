#!/bin/sh
# vim:set ft=sh:

js -s -w -C $1 2>&1 \
	| grep ':$' \
#	| grep -v 'test for equality' \


