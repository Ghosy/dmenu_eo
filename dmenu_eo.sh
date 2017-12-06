#!/bin/bash
#
# This program allows the use of dmenu to view information from the ESPDIC
# Copyright (c) 2017 Zachary Matthews.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

set -euo pipefail; [[ "$TRACE" ]] && set -x

# ESPDIC download location
espdic_dl="http://www.denisowski.org/Esperanto/ESPDIC/espdic.txt"

# cache from dmenu_path
cachedir=${XDG_CACHE_HOME:-"$HOME/.cache"}
if [ -d "$cachedir" ]; then
	cache=$cachedir/espdic
else
	cache=$HOME/.espdic # if no xdg dir, fall back to dotfile in ~
fi

# Check for wget
if ! type wget >>/dev/null; then
	echo "Wget is not installed. Please install wget."
	exit 1
fi
# Check for dmenu
if ! type dmenu >>/dev/null; then
	echo "Dmenu is not installed. Please install dmenu."
	exit 1
fi

# If ESPDIC is installed
if [ ! -r $cache ]; then
	wget -o /dev/null -O "$cache" $espdic_dl >> /dev/null
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
