hh=$HOSTNAME
uu=$USER
col=32
TITLEBAR='\[\033]0; \w\007\]'
PS1="${TITLEBAR}
\[\e[${col}m\]$uu@$hh \[\e[33m\]\w
\[\e[${col}m\]\$\[\e[m\] "

path=(
	"$HOME/bin"
	"/usr/local/bin"
	"/usr/bin"
	"/bin"
)
# Convert array to colon-separated PATH
IFS=:
export PATH="${path[*]}:$PATH"
unset IFS

alias lm='ls -altr'

# Load extra rc
function load-extra() {
	if [[ -f "$1" ]]; then
		echo " * Loading extra $1"
		source "$1"
	else
		echo " * Loading extra $1 (not found)"
	fi
}

load-extra "$HOME/.cargo/env"
load-extra "$HOME/.local/bin/env"
load-extra "$HOME/.nvm/nvm.sh"


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/cho45/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
