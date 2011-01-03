# vim:set ft=zsh:
# ~/.zshrc is standalone for copy to remote server as a file
# ~/.zsh/mine.zshrc is located on local machines

stty intr 

PATHS=(
	$HOME/bin
	$HOME/project/commands/bin
	$HOME/sdk/play
	$HOME/sdk/android/tools
	$HOME/sdk/flex/bin
	/usr/local/ruby1.9/bin
	/usr/local/scala/bin
	/usr/local/vim7/bin
	/usr/local/tscreen/bin
	/usr/local/screen/bin
	/opt/local/sbin
	/opt/local/bin
	/usr/local/bin
	$PATH
)
export PATH=${(j.:.)PATHS}

unset PS1

export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export PAGER="less --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESS='-X -i -P ?f%f:(stdin).  ?lb%lb?L/%L..  [?eEOF:?pb%pb\%..]'
export EDITOR=vim
export LANG=ja_JP.UTF-8

## Application environment variables
export MYSQL_PS1="(\u@\h) [\d]> "
export PERL5LIB=lib:$HOME/lib/perl
export NYTPROF=sigexit=int,hup:trace=2:start=no
export PERL_CPANM_OPT="--verbose --sudo --prompt --mirror http://cpan.cpantesters.org"
export RIDGE_ENV=test
export FLEX_HOME=$HOME/sdk/flex4sdk

bindkey -e
bindkey -D vicmd
bindkey -r '^X^V'

## modules
autoload zargs

autoload -U url-quote-magic
zle -N self-insert url-quote-magic

autoload -U edit-command-line
zle -N edit-command-line
bindkey "^F" edit-command-line

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
#setopt auto_cd
setopt correct
setopt auto_name_dirs
#setopt append_history
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
#setopt print_exit_value

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

HISTSIZE=9999999
HISTFILE=~/.zsh_history
SAVEHIST=9999999

# abbr
typeset -A abbreviations
abbreviations=(
	"L"    "| \$PAGER"
	"G"    "| grep"

	"H"     "$HOME/project/Hatena-"

	"HEAD^"     "HEAD\\^"
	"HEAD^^"    "HEAD\\^\\^"
	"HEAD^^^"   "HEAD\\^\\^\\^"
	"HEAD^^^^"  "HEAD\\^\\^\\^\\^\\^"
	"HEAD^^^^^" "HEAD\\^\\^\\^\\^\\^"

	"sipp"  "server_ips"
	"mysql" "mysql -unobody -pnobody -h"

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
bindkey "."   magic-abbrev-expand-and-insert
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

alias ..='cd ..'

alias wget='noglob wget --no-check-certificate'

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

# Load extra rc

if [[ -f "$HOME/.zsh/mine.zshrc" ]]; then
	source "$HOME/.zsh/mine.zshrc"
fi

if [[ -f "$HOME/perl5/perlbrew/etc/bashrc" ]]; then
	source $HOME/perl5/perlbrew/etc/bashrc
fi

