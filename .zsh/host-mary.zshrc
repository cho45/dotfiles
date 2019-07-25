# vim:ft=zsh:
export LANG=ja_JP.UTF-8

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

export PATH=/usr/local/mysql/bin:$PATH
export PATH=$HOME/project/hatena/commands/bin:$PATH

# for shared-mime-info
export XDG_DATA_HOME=/usr/local/share
# update-mime-database /usr/local/share/mime

export CLASSPATH=.:lib/\*.jar:$JPATH/classes.jar

export JAVA_HOME=$(/usr/libexec/java_home -v 1.8.0)

export CGO_CFLAGS="-I/usr/local/include"
export CGO_LDFLAGS="-L/usr/local/lib"


