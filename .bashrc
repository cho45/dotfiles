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
. "$HOME/.cargo/env"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/cho45/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/cho45/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/cho45/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/cho45/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

