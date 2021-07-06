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

export LC_ALL="en_US.UTF-8"
export LANG=en_US.UTF-8

alias clip="/mnt/c/Windows/System32/clip.exe"
alias open="/mnt/c/Windows/explorer.exe"

alias -g CP="| clip"



