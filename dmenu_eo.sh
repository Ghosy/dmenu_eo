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
	# Add lines using x system to dictionary
	sed -i -e '/\xc4\x89\|\xc4\x9d\|\xc4\xb5\|\xc4\xa5\|\xc5\xad\|\xc5\x9d\|\xc4\xa4\|\xc4\x88\|\xc4\x9c\|\xc4\xb4\|\xc5\x9c\|\xc5\xac/{p; s/\xc4\x89/cx/g; s/\xc4\x9d/gx/g; s/\xc4\xb5/jx/g; s/\xc4\xa5/hx/g; s/\xc5\xad/ux/g; s/\xc5\x9d/sx/g; s/\xc4\xa4/HX/g; s/\xc4\x88/CX/g; s/\xc4\x9c/GX/g; s/\xc4\xb4/JX/g; s/\xc5\x9c/SX/g; s/\xc5\xac/UX/g;}' $cache
fi

cat "$cache" | dmenu -l 10 "$@"
