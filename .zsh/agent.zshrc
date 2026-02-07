export CI=1
export CONTINUOUS_INTEGRATION=true
export DEBIAN_FRONTEND=noninteractive
export PAGER=cat
export LC_ALL=C
export EDITOR=true
unset HISTFILE
unsetopt ignore_eof
unsetopt correct

PROMPT_EXIT="%(?..exit %?
)
"

PROMPT="$PROMPT_EXIT\$ "
RPROMPT=''
