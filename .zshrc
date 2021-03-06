# vim:set ft=zsh:
# ~/.zshrc is standalone for copy to remote server as a file
# ~/.zsh/mine.zshrc is located on local machines
clear
echo " > Initializing .zshrc"

stty intr 

export GOPATH=$HOME/go

# tied to $PATH
path=(
	$HOME/bin
	$HOME/project/commands/bin
	$HOME/sdk/play
	$HOME/Library/Android/sdk/platform-tools
	$HOME/sdk/apache-maven/bin
	$HOME/.rbenv/bin
	$HOME/app/vim/bin
	$HOME/app/argyll/bin
	$HOME/app/depot_tools
	$HOME/app/node/bin
	$HOME/anaconda3/bin
	$HOME/sdk/*/bin(N)
	$HOME/.cargo/bin
#	$HOME/.platformio/packages/toolchain-gccarmnoneeabi/bin

	/usr/local/opt/llvm/bin
	/usr/local/opt/go/libexec/bin
	/usr/local/opt/ruby/bin

	/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin
	/usr/local/scala/bin
	/usr/local/screen/bin
    /usr/local/go/bin
	$GOPATH/bin

	/usr/local/sbin
	/usr/local/bin

	/usr/bin
	/bin
	/usr/sbin
	/sbin
)

# tie
typeset -xT RUBYLIB rubylib
typeset -U rubylib
rubylib=(
	lib
	$HOME/lib/ruby
)

# tie
typeset -xT PERL5LIB perl5lib
typeset -U perl5lib
perl5lib=(
	lib
	$HOME/lib/perl
)

unset PS1

export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export PAGER="less --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESS='-X -i -P ?f%f:(stdin).  ?lb%lb?L/%L..  [?eEOF:?pb%pb\%..]'
export EDITOR=vim
export LANG=ja_JP.UTF-8

## Application environment variables
export MYSQL_PS1="(\u@\h) [\d]> "
export NYTPROF=sigexit=int,hup:trace=2:start=no
#export PERL_CPANM_OPT="--verbose --sudo --prompt --mirror http://cpan.cpantesters.org"
export PERL_CPANM_OPT="--verbose --prompt"
export FLEX_HOME=$HOME/sdk/flex4sdk
export _JAVA_OPTIONS="-Duser.language=en -Dfile.language=UTF-8"

bindkey -e
bindkey -D vicmd
bindkey -r '^X^V'

## modules
autoload zargs

# The eight base colors are: black, red, green, yellow, blue, magenta, cyan, and white.  Each of these has codes for foreground and background.  In addition  there  are  seven  intensity  attributes:
# bold,  faint,  standout,  underline,  blink,  reverse,  and conceal.  Finally, there are seven codes used to negate attributes: none (reset all attributes to the defaults), normal (neither bold nor
# faint), no-standout, no-underline, no-blink, no-reverse, and no-conceal.
autoload colors
colors;

autoload -Uz is-at-least

autoload -U url-quote-magic
zle -N self-insert url-quote-magic

autoload -U edit-command-line
zle -N edit-command-line
bindkey "^F" edit-command-line

if is-at-least 4.3.10; then
	bindkey '^R' history-incremental-pattern-search-backward
	bindkey '^S' history-incremental-pattern-search-forward
fi

### completion
autoload -U compinit
compinit -u
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
compdef -d _git
compdef -d git

### predict
autoload predict-on
zle -N predict-on
zle -N predict-off
bindkey '^X^Z' predict-on
bindkey '^Z' predict-off
zstyle ':predict' verbose true

## setopt
setopt print_eight_bit
setopt auto_menu
setopt transient_rprompt
setopt correct
setopt auto_name_dirs
setopt inc_append_history
setopt share_history
setopt auto_remove_slash
setopt auto_param_keys
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt prompt_subst
setopt pushd_ignore_dups
setopt auto_pushd
setopt extended_glob
setopt list_types
setopt no_beep
setopt always_last_prompt
setopt cdable_vars
setopt sh_word_split
setopt ignore_eof
setopt magic_equal_subst
setopt long_list_jobs

help! () { zle -M "E478: Don't panic!" }
zle -N help!

# show exit status
# (override at mine.zshrc)
PROMPT_EXIT="%(?..exit %?
)
"

if [[ -n $SSH_CONNECTION ]]; then
	HOST_ADDRESS=$(echo $SSH_CONNECTION | cut -d " " -f 3)
	PROMPT_CWD="%{[31mSSH $LOGNAME@$HOST_ADDRESS%} %{[33m%}%~%{[m%}"
else
	PROMPT_CWD="%{[31mLONELY%} %{[33m%}%~%{[m%}"
fi
PROMPT_L="
%{[34m%}$HOSTNAME$%{[m%}%{[m%} "

PROMPT="$PROMPT_EXIT$PROMPT_CWD$PROMPT_L"
RPROMPT='%{[32m%}[%n@%m]%{[m%}'

REPORTTIME=3
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=9999999

# abbr
typeset -A abbreviations
abbreviations=(
	"L"    "| \$PAGER"
	"G"    "| grep"
	"P"    "| peco"

	"HEAD^"     "HEAD\\^"
	"HEAD^^"    "HEAD\\^\\^"
	"HEAD^^^"   "HEAD\\^\\^\\^"
	"HEAD^^^^"  "HEAD\\^\\^\\^\\^\\^"
	"HEAD^^^^^" "HEAD\\^\\^\\^\\^\\^"

	# typo
	"lkm"   "lm"
	"it"    "git"
	"gitp"  "git"
	"ush"   "push"
	"psuh"  "push"
	"puhs"  "push"
)

function magic-abbrev-expand () {
	local MATCH
	LBUFFER=${LBUFFER%%(#m)[-_a-zA-Z0-9^]#}
	LBUFFER+=${abbreviations[$MATCH]:-$MATCH}

	MATCH=""
	# match quoted windows path
	LBUFFER=${LBUFFER%%(#m)\"C:\\*\"}
	if [[ "$MATCH" == "" ]]; then
		echo NOTMATCHED >> /tmp/test
		# match unquoted windows path
		LBUFFER=${LBUFFER%%(#m)[^\"]C:\\[^ ]#}
	fi
	if [[ "$MATCH" != "" ]]; then
		MATCH=${MATCH//C:\\/\/mnt\/c\/}
		MATCH=${MATCH//\\/\/}
		LBUFFER+=$MATCH
	fi
}

# BK: name of this function must be builtin
# http://subtech.g.hatena.ne.jp/cho45/20100814/1281726377
function magic-space () {
	magic-abbrev-expand
	zle self-insert
}

function magic-abbrev-expand-and-insert () {
	magic-abbrev-expand
	zle self-insert
}

function magic-abbrev-expand-and-insert-complete () {
	magic-abbrev-expand
	zle self-insert
	zle expand-or-complete
}

function magic-abbrev-expand-and-accept () {
	magic-abbrev-expand
	zle accept-line
}

function magic-abbrev-expand-and-normal-complete () {
	magic-abbrev-expand
	zle expand-or-complete
}

function no-magic-abbrev-expand () {
	LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N magic-abbrev-expand-and-magic-space
zle -N magic-abbrev-expand-and-insert
zle -N magic-abbrev-expand-and-insert-complete
zle -N magic-abbrev-expand-and-normal-complete
zle -N magic-abbrev-expand-and-accept
zle -N no-magic-abbrev-expand
zle -N magic-space # BK
bindkey "\r"  magic-abbrev-expand-and-accept # Can't do M-x RET because of not builtin command name...
bindkey "^J"  accept-line # no magic
bindkey " "   magic-space # BK
#bindkey "."   magic-abbrev-expand-and-insert
bindkey "^I"  magic-abbrev-expand-and-normal-complete

function expand-to-home-or-insert () {
	if [ "$LBUFFER" = "" -o "$LBUFFER[-1]" = " " ]; then
		LBUFFER+="~/"
	else
		zle self-insert
	fi
}

zle -N expand-to-home-or-insert
bindkey "\\"  expand-to-home-or-insert

if [ `uname` = "FreeBSD" -o `uname` = "Darwin" ]; then
	alias ls='ls -FG'
else
	alias ls='ls -F --color'
fi
alias lm='ls -altrh'
alias ps='ps aux'
alias zcat='gzip -dfc'


alias ..='cd ..'

alias wget='noglob wget --no-check-certificate'

NUMCPUS=$(ruby -retc -e 'puts Etc.nprocessors')
alias make="make -j$NUMCPUS"

alias :q=exit

if [ `uname` = "Darwin" ]; then
	alias nopaste='curl --form paste_code=@- pastebin.com/api_public.php >&1 > >(pbcopy) > >(open `cat`) '
else
	alias nopaste='curl --data paste_code=@- pastebin.com/api_public.php'
fi

# Ensure no background processes
function reload () {
	local j
	jobs > /tmp/$$-jobs
	j=$(</tmp/$$-jobs)
	if [ "$j" = "" ]; then
		exec zsh
	else
		fg
	fi
}

function snatch () {
	gdb -p $1 -batch -n -x =( echo -e "p (int)open(\"/proc/$$/fd/1\", 1)\np (int)dup2(\$1, 1)\np (int)dup2(\$1, 2)" )
}

function gres () {
	vim -c "argdo %s/$1/$2/gce | update" ${@[3, -1]}
}

function history () {
	grep "${@[1, -1]}" ~/.zsh_history | cut -s -d ";" -f 2-10
}

# infinitely execute the command
# ssh -o PreferredAuthentications=publickey ....
function oo () {
	while :; do;
		${@[1, -1]}
	done
}

# Load extra rc

function load-extra () {
	echo "$fg[green] * Loading extra $reset_color$1"
	if [[ -f $1 ]]; then
		source $1
	fi
}

echo "$fg[blue] # Loading extra files...$reset_color"

load-extra "$HOME/.zsh/mine.zshrc"
load-extra "$HOME/perl5/perlbrew/etc/bashrc"
load-extra "$HOME/.secret.zshrc"

if [[ -d "$HOME/.rbenv" ]]; then
	echo " * rbenv init"
	eval "$(rbenv init -)"
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

