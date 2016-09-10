#!/bin/bash

# ESPDIC download location
espdic_dl="http://www.denisowski.org/Esperanto/ESPDIC/espdic.txt"

# cache from dmenu_path
cachedir=${XDG_CACHE_HOME:-"$HOME/.cache"}
if [ -d "$cachedir" ]; then
	cache=$cachedir/espdic
else
	cache=$HOME/.espdic # if no xdg dir, fall back to dotfile in ~
fi

# If ESPDIC is installed
if [ ! -r $cache ]; then
	wget -O "$cache" $espdic_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "Wget of espdic failed" 1>&2
		exit 1
	fi
	# Convert DOS newline to Unix
	sed -i 's/.$//' $cache
fi

cat "$cache" | dmenu -l 10 "$@"
