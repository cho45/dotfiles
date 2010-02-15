# vim:set ft=zsh

export GISTY_DIR="$HOME/sketch/gists"
export PERL_AUTOINSTALL="--defaultdeps"

cheat-sheet () { zle -M "`cat ~/.zsh/cheat-sheet`" }
zle -N cheat-sheet
# C-[ :cheat-sheet

# プロンプトの設定。
# 終了ステータスが 0 でなければ終了ステータスを表示する。
PROMPT_EXIT="%(?..exit %?
)
"
PROMPT_CWD=" %{[33m%}%~%{[m%}"
PROMPT_CMD="%{[32m%} | q ド _ リ|$ <%{[m%}%{[m%} "
# precmd で設定される
PROMPT_CWD_ADD=""

alias svn='svnwrapper.rb'
alias b='todo.pl editdump'

# for screen
preexec () {
	# see [zsh-workers:13180]
	# http://www.zsh.org/mla/workers/2000/msg03993.html
	emulate -L zsh
	local -a cmd; cmd=(${(z)2})

	if [[ $SSH_AGENT_PID != "" ]]; then
		cmd[1]="@$cmd[1]"
	fi

	case $cmd[1] in
		fg)
			if (( $#cmd == 1 )); then
				cmd=(builtin jobs -l %+)
			else
				cmd=(builtin jobs -l $cmd[2])
			fi
			;;
		%*)
			cmd=(builtin jobs -l $cmd[1])
			;;
		cd)
			if (( $#cmd == 2)); then
				cmd[1]=$cmd[2]
			fi
			;&
		*)
			echo -n "k$cmd[1]:t\\"
			prev=$cmd[1]
			return
			;;
	esac

	local -A jt; jt=(${(kv)jobtexts})


	$cmd >>(read num rest
		cmd=(${(z)${(e):-\$jt$num}})
		echo -n "k$cmd[1]:t\\") 2>/dev/null

	prev=$cmd[1]
}

precmd () {
	# Set title of screen window
	echo -n "k:$prev\\"

	# for git
	if command git rev-parse --is-inside-work-tree 1>/dev/null 2>&1 ; then
		update-git-status
	fi

	if [[ ${DYLD_INSERT_LIBRARIES:#libtsocks} != "" ]]; then
		local proxy=$(command ps -ocommand= | grep "^ssh .*\-D *8081" | awk '{ print $NF }')
		PROMPT_CMD_ADD="$PROMPT_CMD_ADD [35m%}[${proxy:-[31mDisconnected[35m}]%{[m%}=$cmd[1]"

		# どこの window が socks 経由になっているかわかったほうがいいので
		echo -n "k:=:$prev\\"
	fi

	# update prompt
	PROMPT="$PROMPT_EXIT$PROMPT_CMD_ADD$PROMPT_CWD$PROMPT_CWD_ADD
$PROMPT_CMD"
	RPROMPT='%{[32m%}[%n@%m]%{[m%}'
	PROMPT_CWD_ADD=""
	PROMPT_CMD_ADD=""
}

chpwd () {
	# for cdd
	_reg_pwd_screennum
}

# ~ (master) のように git レポジトリ以下では git のブランチを表示する
update-git-status () {
	local gitdir=$(command git rev-parse --git-dir)
	local ret=''

	if   [[ -d "$gitdir/rebase-apply" ]]; then
		local next=$(< $gitdir/rebase-apply/next)
		local last=$(< $gitdir/rebase-apply/last)
		if [[ -n $next && -n $last ]]; then
			local curr=$[ $next - 1]
		fi
		ret="rebase[$curr/$last]"
	elif [[ -d "$gitdir/rebase-merge" ]]; then
		if [[ -f "$gitdir/rebase-merge/interactive" ]]; then
			local left=$(grep '^[pes]' $git_dir/rebase-merge/git-rebase-todo | wc -l)
			if [[ -n $left ]]; then
				left=$[ $left + 1 ]
			fi
			ret="rebase[i, $left left]"
		else
			ret="rebase[m]"
		fi
	elif [[ -f "$gitdir/MERGE_HEAD" ]]; then
		ret="merge[]"
	elif [[ -f "$gitdir/BISECT_START" ]]; then
		local start=$(< $gitdir/BISECT_START)
		local bad=$(command git rev-parse --verify refs/bisect/bad)
		local good="$(command git for-each-ref --format='^%(objectname)' "refs/bisect/good-*" | tr '\012' ' ')"
		local skip=$(command git for-each-ref --format='%(objectname)' "refs/bisect/skip-*" | tr '\012' ' ')
		eval "$(command git rev-list --bisect-vars "$good" "$bad" -- $(< $gitdir/BISECT_NAMES))"

		ret="bisect[$start, $bisect_nr left]"
	else
		ret=$(command git branch -a 2>/dev/null | grep "^*" | tr -d '\* ')
	fi

	if [[ -n $ret ]]; then
		PROMPT_CWD_ADD="$PROMPT_CWD_ADD [32m%}($ret)%{[m%}"
	fi
}

# 新しく screen window をつくり、カレントディレクトリを実行元のディレクトリに
function n () {
	screen -X eval "chdir $PWD" "screen" "chdir"
}

function git () {
	if [[ -e '.svn' ]]; then
		if [[ $1 == "log" ]]; then
			command svn $@ | $PAGER
		else
			command svn $@
		fi
		echo
		echo "x| _ |x < .svn があったので svn コマンドにしました!"
	else
		if [[ $1 == "" ]]; then
			# git ってだけうったときは status 表示
			cat =(command git --no-pager branch-recent) \
			    =(command git --no-pager diff --stat --color-words) \
			    =(command git --no-pager status) \
			    | $PAGER
		elif [[ $1 == "log" ]]; then
			# 常に diff を表示してほしい
			command git log -p ${@[2, -1]}
		else
			command git $@
		fi
	fi
}

function gistysearch () {
	local pwd
	pwd=$PWD
	cd $GISTY_DIR
	for i in *(/); do
		cd $i
		git grep "$1" | sed "s/^/$i: /"
		cd - >/dev/null
	done
	cd $pwd
}

function anco () {
	if command git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
		command git grep $@
	else
		command ack --all --with-filename $@ | $PAGER
	fi
}

function socks () {
	if [[ ${DYLD_INSERT_LIBRARIES:#libtsocks} == "" ]]; then
		. tsocks on
	else
		. tsocks off
	fi
}

# screen cd
source $HOME/.zsh/cdd

# window num -> tty の対応ができるように
tty > /tmp/screen-tty-$WINDOW

# ホストごとの設定を読みこむ
h="${HOST%%.*}"
if [[ -f "$HOME/.zsh/host-$h.zshrc" ]]; then
	source "$HOME/.zsh/host-$h.zshrc"
fi
