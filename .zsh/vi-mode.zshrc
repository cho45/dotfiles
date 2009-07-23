# vim:ft=zsh:

bindkey -v
bindkey "^[Q" push-line
bindkey "^Q" push-line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '^N' down-line-or-history
bindkey '^O' accept-line-and-down-history
bindkey '^P' up-line-or-history
bindkey '^H' backward-delete-char
bindkey '^[:' execute-named-cmd

unsetopt promptcr

# http://www.zsh.org/mla/users/2002/msg00108.html

#
# Set vi mode status bar
#

#
# Reads until the given character has been entered.
#
readuntil () {
	typeset a
	while [ "$a" != "$1" ]
	do
		read -E -k 1 a
	done
}

#
# If the $SHOWMODE variable is set, displays the vi mode, specified by
# the $VIMODE variable, under the current command line.
# 
# Arguments:
#
#   1 (optional): Beyond normal calculations, the number of additional
#   lines to move down before printing the mode.  Defaults to zero.
#
showmode() {
	typeset movedown
	typeset row

	# Do not echo back
	stty -echo > /dev/null 2>&1

	# Get number of lines down to print mode
	movedown=$(($(echo "$RBUFFER" | wc -l) + ${1:-0}))

	# Get current row position
	echo -n "\e[6n"
	row="${${$(readuntil R)#*\[}%;*}"

	# Are we at the bottom of the terminal?
	if [ $((row+movedown)) -gt "$LINES" ]
	then
		# Scroll terminal up one line
		echo -n "\e[1S"

		# Move cursor up one line
		echo -n "\e[1A"
	fi

	# Save cursor position
	echo -n "\e[s"

	# Move cursor to start of line $movedown lines down
	echo -n "\e[$movedown;E"

	# Change font attributes
	echo -n "\e[1m"

	# Has a mode been set?
	if [ -n "$VIMODE" ]
	then
		# Print mode line
		echo -n "-- $VIMODE -- "
	else
		# Clear mode line
		echo -n "\e[0K"
	fi

	# Restore font
	echo -n "\e[0m"

	# Restore cursor position
	echo -n "\e[u"

	# Restore echo back
	stty echo > /dev/null 2>&1
}

clearmode() {
	VIMODE= showmode
}

#
# Temporary function to extend built-in widgets to display mode.
#
#   1: The name of the widget.
#
#   2: The mode string.
#
#   3 (optional): Beyond normal calculations, the number of additional
#   lines to move down before printing the mode.  Defaults to zero.
#
makemodal () {
	# Create new function
	eval "$1() { zle .'$1'; ${2:+VIMODE='$2'}; showmode $3 }"

	# Create new widget
	zle -N "$1"
}

# Extend widgets
makemodal vi-add-eol           INSERT
makemodal vi-add-next          INSERT
makemodal vi-change            INSERT
makemodal vi-change-eol        INSERT
makemodal vi-change-whole-line INSERT
makemodal vi-insert            INSERT
makemodal vi-insert-bol        INSERT
makemodal vi-open-line-above   INSERT
makemodal vi-substitute        INSERT
makemodal vi-open-line-below   INSERT 1
makemodal vi-replace           REPLACE
makemodal vi-cmd-mode          NORMAL

unfunction makemodal

