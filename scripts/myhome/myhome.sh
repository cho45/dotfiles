#!/bin/sh

ORIG_HOME=$HOME
export HOME=$ORIG_HOME/cho45-works

mkdir $HOME
cd $HOME
wget --no-check-certificate https://raw.github.com/cho45/dotfiles/master/.bashrc
exec bash

