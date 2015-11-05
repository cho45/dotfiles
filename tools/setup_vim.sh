#!/bin/sh
set -e

cd
cd tmp

if [ -d vim ]; then
	cd vim
	git pull
else
	git clone --depth 1 https://github.com/vim/vim.git
	cd vim
fi

cd src

# make distclean

./configure \
	--prefix=$HOME/app/vim \
	--enable-multibyte \
	--enable-gpm \
	--enable-cscope \
	--with-features=huge \
	--enable-fontset \
	--disable-gui \
	--without-x \
	--disable-xim \
	--disable-perlinterp

make -j 2
make install


