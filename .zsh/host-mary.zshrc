# vim:ft=zsh:
echo "Mary!!"

export LANG=ja_JP.UTF-8

if [[ -n $WINDOW ]]; then
	screen -X eval "escape ^yy"
fi

# use utf8 with pbcopy/pbpaste
export __CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'
alias -g CP="| pbcopy"

alias port="port -v"
alias ql='qlmanage -p "$@" >& /dev/null'
alias lock='open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app'

#alias mysql=/usr/local/mysql/bin/mysql
#alias mysqladmin=/usr/local/mysql/bin/mysqladmin
#alias mysqldump=/usr/local/mysql/bin/mysqldump

export PATH=/usr/local/mysql/bin:$PATH
export PATH=$HOME/project/hatena/commands/bin:$PATH

# for MacPorts shared-mime-info
export XDG_DATA_HOME=/opt/local/share


JPATH=/System/Library/Frameworks/JavaVM.framework/Versions/1.4.2/Classes
export CLASSPATH=.:$JPATH/classes.jar

export JAVA_HOME=/Library/Java/Home

