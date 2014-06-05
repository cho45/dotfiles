#!/bin/sh
set -e

cd
cd tmp
wget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
tar xjvf vim-7.4.tar.bz2
cd vim74
./configure --prefix=$HOME/app/vim --enable-multibyte --enable-gpm --enable-cscope --with-features=huge --enable-fontset --disable-gui --without-x --disable-xim --disable-perlinterp
make -j 2
make install


