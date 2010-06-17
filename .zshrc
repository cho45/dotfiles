# vim:set ft=zsh:
# ~/.zshrc はサーバなどに転送して単体で使えるように
# 自分管理のマシンなどは ~/.zsh/mine.zshrc に追加の設定をする

stty intr 

export RIDGE_ENV=test
export FLEX_HOME=$HOME/sdk/flex4sdk

PATHS=(
	$HOME/bin
	$HOME/project/commands/bin
	$HOME/sdk/android/tools
	$HOME/sdk/flex/bin
	/usr/local/ruby1.9/bin
	/usr/local/scala/bin
	/usr/local/vim7/bin
	/usr/local/screen/bin
	/opt/local/sbin
	/opt/local/bin
	/usr/local/bin
	$PATH
)
export PATH=${(j.:.)PATHS}

unset PS1

export MYSQL_PS1="(\u@\h) [\d]> "
export PAGER="less --quit-if-one-screen --RAW-CONTROL-CHARS"
export LESS='-X -i -P ?f%f:(stdin).  ?lb%lb?L/%L..  [?eEOF:?pb%pb\%..]'
export EDITOR=vim
export LANG=ja_JP.UTF-8

export PERL5LIB=lib:$HOME/lib/perl
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

bindkey -e
bindkey -D vicmd
bindkey -r '^X^V'

help! () { zle -M "E478: Don't panic!" }
zle -N help!

autoload zargs

# 日本語用
setopt print_eight_bit

# 補完キー連打で候補移動
setopt auto_menu

# ディレクトリ名だけで cd
#setopt auto_cd

# コマンド名スペルチェック
setopt correct

# 
setopt auto_name_dirs

# ヒストリは追記
# setopt append_history

# シェルのプロセスごとに履歴を共有
setopt share_history

# 実行時にディレクトリのスラッシュ外す
setopt auto_remove_slash

# 括弧とか補完
setopt auto_param_keys

# ヒストリを詳しく
setopt extended_history

# 連続する同じコマンドは記録しない
setopt hist_ignore_dups

# スペースから始まるコマンドは記録しない
setopt hist_ignore_space

# すごいプロンプト
setopt prompt_subst

# 同じディレクトリなら pushd しない
setopt pushd_ignore_dups

setopt auto_pushd

# 高機能な glob
setopt extended_glob

# 補完候補のファイルタイプ表示
setopt list_types

# うるさい
setopt no_beep

setopt always_last_prompt
setopt cdable_vars
setopt sh_word_split
setopt ignore_eof

# 終了コード表示。冗長
#setopt print_exit_value

# 補完
autoload -U compinit
compinit -u
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

autoload predict-on
zle -N predict-on
zle -N predict-off
bindkey '^X^Z' predict-on
bindkey '^Z' predict-off
zstyle ':predict' verbose true

# git の補完うざいし……
compdef -d _git
compdef -d git

# プロンプトの設定。
# 終了ステータスが 0 でなければ終了ステータスを表示する。
# 自分の環境の場合は mine.zshrc で上書きされる。
PROMPT_EXIT="%(?..exit %?
)
"
PROMPT_CWD="%{[31mREMOTE%} %{[33m%}%~%{[m%}"
PROMPT_L="
%{[34m%}%n@%m$%{[m%}%{[m%} "

PROMPT="$PROMPT_EXIT$PROMPT_CWD$PROMPT_L"
RPROMPT='%{[32m%}[%n@%m]%{[m%}'

HISTSIZE=9999999
HISTFILE=~/.zsh_history
SAVEHIST=9999999

if [ `uname` = "FreeBSD" -o `uname` = "Darwin" ]
then
	alias ls='ls -FG'
else
	alias ls='ls -F --color'
fi
alias lm='ls -altrh'
alias ps='ps aux'

alias ..='cd ..'

alias wget='noglob wget --no-check-certificate'

alias :q=exit
alias sudo='sudo env PATH=$PATH'

if [ `uname` = "Darwin" ]; then
	alias nopaste='curl -F file=@- nopaste.com/a >&1 > >(pbcopy) > >(open `cat`) '
	alias nonopaste='pbpaste | nopaste'
else
	alias nopaste='curl -F file=@- nopaste.com/a'
fi

autoload -U edit-command-line
zle -N edit-command-line
bindkey "^F" edit-command-line

# abbr
typeset -A abbreviations
abbreviations=(
	"L"    "| \$PAGER"
	"G"    "| grep"
	"CC"    "lib/*/Controller/" # Catalyst Controller
	"CS"    "lib/*/Schema/"     # Catalyst Schema
	"CI"    "lib/*/I18N/"       # Catalyst I18N
	"CV"    "lib/*/View/"       # Catalyst View
	"CM"    "lib/*/Model/"      # Catalyst Model

	"H"     "$HOME/project/Hatena-"

	"HE"    "lib/**/Engine/"
	"HM"    "lib/**/MoCo/"
	"HA"    "lib/**/App/"
	"HC"    "lib/**/Config.pm"

	"HEAD^"     "HEAD\\^"
	"HEAD^^"    "HEAD\\^\\^"
	"HEAD^^^"   "HEAD\\^\\^\\^"
	"HEAD^^^^"  "HEAD\\^\\^\\^\\^\\^"
	"HEAD^^^^^" "HEAD\\^\\^\\^\\^\\^"

	# typo
	"lkm"  "lm"
	"it"  "git"
	"gitp"  "git"

	"mysql" "mysql -unobody -pnobody -h"
)

magic-abbrev-expand () {
	local MATCH
	LBUFFER=${LBUFFER%%(#m)[-_a-zA-Z0-9^]#}
	LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
}

magic-abbrev-expand-and-insert () {
	magic-abbrev-expand
	zle self-insert
}

magic-abbrev-expand-and-insert-complete () {
	magic-abbrev-expand
	zle self-insert
	zle expand-or-complete
}

magic-abbrev-expand-and-accept () {
	magic-abbrev-expand
	zle accept-line
}

magic-abbrev-expand-and-normal-complete () {
	magic-abbrev-expand
	zle expand-or-complete
}

no-magic-abbrev-expand () {
	LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N magic-abbrev-expand-and-insert
zle -N magic-abbrev-expand-and-insert-complete
zle -N magic-abbrev-expand-and-normal-complete
zle -N magic-abbrev-expand-and-accept
zle -N no-magic-abbrev-expand
bindkey "\r"  magic-abbrev-expand-and-accept # M-x RET できなくなる
bindkey "^J"  accept-line # no magic
bindkey " "   magic-abbrev-expand-and-insert
bindkey "."   magic-abbrev-expand-and-insert
bindkey "^I"  magic-abbrev-expand-and-normal-complete

expand-to-home-or-insert () {
	if [ "$LBUFFER" = "" -o "$LBUFFER[-1]" = " " ]; then
		LBUFFER+="~/"
	else
		zle self-insert
	fi
}

zle -N expand-to-home-or-insert
bindkey "\\"  expand-to-home-or-insert

# vim とかが露頭に迷わないように
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

# http://subtech.g.hatena.ne.jp/secondlife/20080604/1212562182
function cdf () {
	local -a tmpparent; tmpparent=""
	local -a filename; filename="${1}"
	local -a file
	local -a num; num=0
	while [ $num -le 10 ]; do
		tmpparent="${tmpparent}../"
		file="${tmpparent}${filename}"
		if [ -f "${file}" ] || [ -d "${file}" ]; then
			cd ${tmpparent}
			break
		fi
		num=$(($num + 1))
	done
}
function cdrake () {
	cdf "Rakefile"
}

function cdcat () {
	cdf "Makefile.PL"
}

function find_dsn () {
	cdf "Capfile"
	cat **/Config.pm | grep dbi:mysql:dbname=$1
	cd -
}

function snatch () {
	gdb -p $1 -batch -n -x =( echo -e "p (int)open(\"/proc/$$/fd/1\", 1)\np (int)dup2(\$1, 1)\np (int)dup2(\$1, 2)" )
}

if [ -f "$HOME/.zsh/mine.zshrc" ]
then
	source "$HOME/.zsh/mine.zshrc"
fi

function scalatmpl () {
	mvn org.apache.maven.plugins:maven-archetype-plugin:1.0-alpha-7:create \
	-DarchetypeGroupId=org.scala-tools.archetypes \
	-DarchetypeArtifactId=scala-archetype-simple \
	-DarchetypeVersion=1.1 \
	-DremoteRepositories=http://scala-tools.org/repo-releases \
	-DgroupId=$1 -DartifactId=$2
}
