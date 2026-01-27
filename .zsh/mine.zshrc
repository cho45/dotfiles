# vim:set ft=zsh:

cheat-sheet () { zle -M "`cat ~/.zsh/cheat-sheet`" }
zle -N cheat-sheet
# C-[ :cheat-sheet

# プロンプトの設定。
# 終了ステータスが 0 でなければ終了ステータスを表示する。
PROMPT_EXIT="%(?..exit %?
)
"
RPROMPT=""
PROMPT_CWD="%{[32m%}[%n@%m] %{[33m%}%~%{[m%}"
PROMPT_CMD="%{[32m%}$ %{[m%}%{[m%} "
# precmd で設定される
PROMPT_CWD_ADD=""

# for screen
preexec () {
	# osascript -e 'tell application "System Events" to key code 103'

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
	PROMPT_CMD_ADD=""
	PROMPT_CWD_ADD=""

	# for git
	update-git-status

	if [[ ${DYLD_INSERT_LIBRARIES:#libtsocks} != "" ]]; then
		# local proxy=$(command ps -ocommand= | grep "^ssh .*\-D *8081" | head -n 1 | awk '{ print $NF }')
		if command ps -ocommand= | grep -v grep | grep "ssh.*10081" > /dev/null; then
			local proxy=Connected
		fi
		PROMPT_CMD_ADD="$PROMPT_CMD_ADD [35m%}[${proxy:-[31mDisconnected[35m}]%{[m%}=$cmd[1]"

		# どこの window が socks 経由になっているかわかったほうがいいので
		echo -n "k:=:$prev\\"
	fi

	if [[ ${PERL5OPT:#lib::core::only} != "" ]]; then
		PROMPT_CWD_ADD="$PROMPT_CWD_ADD [36m%}*carton*%{[m%}"
	fi

	# update prompt
	PROMPT="$PROMPT_EXIT$PROMPT_CMD_ADD$PROMPT_CWD$PROMPT_CWD_ADD
$PROMPT_CMD"
}

chpwd () {
	if [[ -n "${WSLENV+x}" ]]; then
		# in WSL
		$HOME/dotfiles/bin/wsl-update-cwds
	fi
}

# ~ (master) のように git レポジトリ以下では git のブランチを表示する
update-git-status () {
	local gitdir="$(command git rev-parse --git-dir 2>/dev/null)"
	if [[ $gitdir != "" ]]; then
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
			if [[ $ret == "(nobranch)" ]]; then
				ret=$(command git name-rev --name-only HEAD)
				ret="($ret)"
			fi
		fi

		if [[ -n $ret ]]; then
			PROMPT_CWD_ADD="$PROMPT_CWD_ADD [32m%}($ret)%{[m%}"
		fi
	fi
}

# 新しく screen window をつくり、カレントディレクトリを実行元のディレクトリに
function n () {
	# screen -X eval "chdir $PWD" "screen" "chdir"
	tmux new-window -c $PWD
}

function git () {
	if [[ $1 == "" ]]; then
		if command git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
			# git ってだけうったときは status 表示
			command git --no-pager branch-recent && \
			command git --no-pager diff --stat --color-words && \
			command git --no-pager status \
			| $PAGER
		else
			echo "Not in git work tree."
		fi
	else
		command git "$@"
	fi
}

function cdd() {
	typeset -A mapping
	local window=$1
	local dir=$(perl -e '$n = shift; print +{ map { split / /, $_, 2 } split /\n/, `tmux list-panes -s -F "#{window_index} #{pane_current_path}"` }->{$n}', $window);
	if [[ $dir == "" ]]; then
		echo "window not found"
	else
		cd "$dir"
	fi
}

bindkey '^x^x' peco-src
bindkey '^x^h' peco-select-history
bindkey '^x^b' peco-git-recent-branches
bindkey '^xb' peco-git-recent-all-branches

# ホストごとの設定を読みこむ
h="${HOST%%.*}"

# プラットフォーム判定でデフォルト設定を読み込む
if [[ -z "$WSLENV" ]]; then
	# Not in WSL
	case "$(uname)" in
		Darwin)
			load-extra "$HOME/.zsh/host-macos.zshrc"
			;;
		Linux)
			load-extra "$HOME/.zsh/host-linux.zshrc"
			;;
	esac
else
	# in WSL
	load-extra "$HOME/.zsh/host-windows.zsh"
fi

# ホスト固有設定 (レポジトリには含めない)
load-extra "$HOME/.zsh/host-$h.zshrc"

