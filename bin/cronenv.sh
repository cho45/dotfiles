#!/bin/sh
env=$(crontab -l 2>/dev/null | perl -anal -e '/^[A-Za-z_]+=/ and print' | tr '\n' ' ')
env - sh -c "$env \$0 \"\$@\"" "$@"
