#!/bin/sh

if [ -f .eslintrc ]; then
	eslint --format unix $1
else
	eslint --config $HOME/.vim/.eslintrc --format unix $1
fi

