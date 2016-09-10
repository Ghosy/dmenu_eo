#!/bin/bash
# cache from dmenu_path
cachedir=${XDG_CACHE_HOME:-"$HOME/.cache"}
if [ -d "$cachedir" ]; then
	cache=$cachedir/espdic
else
	cache=$HOME/.espdic # if no xdg dir, fall back to dotfile in ~
fi

cat "$cache" | dmenu -l 10 "$@"
