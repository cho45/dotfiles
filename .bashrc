hh=$HOSTNAME
uu=$USER
col=32
TITLEBAR='\[\033]0; \w\007\]'
PS1="${TITLEBAR}
\[\e[${col}m\]$uu@$hh \[\e[33m\]\w
\[\e[${col}m\]\$\[\e[m\] "

export PATH="$HOME/bin:$HOME/lib/ruby/gems/1.8/bin:/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin:$PATH"
export GEM_HOME="$HOME/lib/ruby/gems/1.8"
export RUBYLIB="$HOME/lib/ruby:$HOME/lib/ruby/site_ruby/1.8"
#export LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/lib:/usr/local/mysql/lib/mysql:/usr/local/pgsql/lib"
export PERL5LIB=$HOME/local/lib/perl5:$HOME/local/lib/perl5/site_perl

alias lm='ls -altr'
alias wget='wget --no-check-certificate'

