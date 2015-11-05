#!/bin/sh
set -x
set -e

cd
cd tmp

if [ -d vim ]; then
	cd vim
	# git pull
else
	git clone --depth 1 https://github.com/vim/vim.git
	cd vim
fi

cd src

# make distclean

./configure \
	--with-compiledby=foobar \
	--prefix=$HOME/app/vim \
	--with-features=huge \
	--enable-multibyte \
	--enable-cscope \
	--enable-fontset \
	--disable-gui \
	--without-x \
	--disable-xim \
	--enable-pythoninterp=yes \
	--enable-perlinterp=yes \
	--enable-rubyinterp=yes

make -j 2
make install


