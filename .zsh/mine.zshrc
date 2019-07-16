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
PROMPT_CMD="%{[32m%} | q ド _ リ|$ <%{[m%}%{[m%} "
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
	elif [[ -e '.hg' ]]; then
		if [[ $1 == "" ]]; then
			command hg status
		else
			command hg $@
		fi
		echo "x| _ |x < .hg があったので hg コマンドにしました!"
	else
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
		elif [[ $1 == "log" ]]; then
			# 常に diff を表示してほしい
			command git log --patch-with-stat ${@[2, -1]}
		elif [[ $1 == "pull" ]]; then
			if [[ ( -x '.git/pull-chain' ) ]]; then
				command git $@
				asyncrun ./.git/pull-chain
			else
				command git $@
			fi
		else
			command git $@
		fi
	fi
}

function socks () {
	if [[ ${DYLD_INSERT_LIBRARIES:#libtsocks} == "" ]]; then
		. tsocks on
	else
		. tsocks off
	fi
}


function peco-select-history () {
	BUFFER=$(perl -nl -e 's/^.*?;//; print' ~/.zsh_history| peco --query "$LBUFFER")
	# zle clear-screen
	zle reset-prompt
	zle accept-line
}
zle -N peco-select-history


function peco-git-recent-branches () {
	local selected_branch=$(git for-each-ref --format='%(refname)' --sort=-committerdate refs/heads | \
		perl -pne 's{^refs/heads/}{}' | \
		peco --query "$LBUFFER")
	if [ -n "$selected_branch" ]; then
		BUFFER="git checkout ${selected_branch}"
		zle accept-line
	fi
	zle clear-screen
}
zle -N peco-git-recent-branches

function peco-git-recent-all-branches () {
	local selected_branch=$(git for-each-ref --format='%(refname)' --sort=-committerdate refs/heads refs/remotes | \
		perl -pne 's{^refs/(heads|remotes)/}{}' | \
		peco --query "$LBUFFER")
	if [ -n "$selected_branch" ]; then
		BUFFER="git checkout -t ${selected_branch}"
		zle accept-line
	fi
	zle clear-screen
}
zle -N peco-git-recent-all-branches


function peco-src () {
	local selected_dir=$(ghq list --full-path | peco --query "$LBUFFER")
	if [ -n "$selected_dir" ]; then
		BUFFER="cd ${selected_dir}"
		zle accept-line
	fi
	zle clear-screen
}
zle -N peco-src


function peco-godoc() {
	local selected_dir=$(ghq list --full-path | peco --query "$LBUFFER")
	if [ -n "$selected_dir" ]; then
		BUFFER="godoc ${selected_dir} | less"
		zle accept-line
	fi
	zle clear-screen
}
zle -N peco-godoc

function cdd() {
	if [[ $1 == "" ]]; then
		local selected_dir=$(lsof -c zsh -w -Ffn0 | perl -anal -e '/cwd/ and print((split /\0.?/)[1])' | uniq | peco)
		if [ -n "$selected_dir" ]; then
			cd "${selected_dir}"
		fi
	else
		local pid
		if [[ $(uname) == "Darwin" ]]; then
			pid=$(command ps -E -o 'pid,command' | WINDOW=$1 perl -anal -e '/STY=$ENV{STY} / and /WINDOW=$ENV{WINDOW} / and /^ *([0-9]+) +[^ ]*zsh/ and print $1')
		else
			pid=$(command ps e -o 'pid,command' | WINDOW=$1 perl -anal -e '/STY=$ENV{STY} / and /WINDOW=$ENV{WINDOW} / and /^ *([0-9]+) +[^ ]*zsh/ and print $1')
		fi

		if [[ $pid == "" ]]; then
			echo "window not found"
		else
			local dir=$(lsof -p $pid -w -Ffn0 | perl -anal -e '/cwd/ and print((split /\0.?/)[1])')
			cd "$dir"
		fi
	fi
}

function pid2screen() {
	local
	command ps -E -o 'command' -p 42629 | perl -anal -e '/STY=$ENV{STY}/ and /WINDOW=([0-9]+)/ and print $1'
}


bindkey '^x^x' peco-src
bindkey '^x^h' peco-select-history
bindkey '^x^b' peco-git-recent-branches
bindkey '^xb' peco-git-recent-all-branches

# ホストごとの設定を読みこむ
h="${HOST%%.*}"
load-extra "$HOME/.zsh/host-$h.zshrc"

