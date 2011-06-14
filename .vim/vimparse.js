#!/bin/sh
# vim:set ft=sh:
# npm install jslint

jslint --browser --no-node --no-es5 $1 | perl -na -e "s/ *[0-9]+ ([0-9]+),([0-9]+)/$1:\$1:\$2/ and print \$_"

