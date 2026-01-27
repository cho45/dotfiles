# vim:ft=zsh:
export LANG=ja_JP.UTF-8
eval "$(/opt/homebrew/bin/brew shellenv)"

if [[ -n $WINDOW ]]; then
	screen -X eval "escape ^yy"
fi

if [[ -n $TMUX ]]; then
	tmux set -g prefix C-y
	tmux bind C-y last-window
	tmux bind y send-prefix
	tmux unbind C-t
	tmux unbind t
fi

# use utf8 with pbcopy/pbpaste
export __CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'
alias -g CP="| pbcopy"

alias ql='qlmanage -p "$@" >& /dev/null'
alias lock='open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app'
alias strace='sudo dtruss'
