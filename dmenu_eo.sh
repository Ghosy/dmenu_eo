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

set -euo pipefail

x_system=false
h_system=false
rebuild=false
# ESPDIC download location
espdic_dl="http://www.denisowski.org/Esperanto/ESPDIC/espdic.txt"

# cache from dmenu_path
cachedir=${XDG_CACHE_HOME:-"$HOME/.cache"}
if [ -d "$cachedir" ]; then
	cache=$cachedir/espdic
else
	cache=$HOME/.espdic # if no xdg dir, fall back to dotfile in ~
fi

print_usage() {
	echo "Usage: dmenu_eo [OPTION]..."
	echo "Options(Agordoj):"
	echo "      --help          display this help message"
	echo "      --helpi         prezenti ĉi tiun mesaĝon de helpo"
	echo "  -h, --hsystem       add H-system entries to dictionary(during rebuild)"
	echo "      --hsistemo      aldoni H-sistemajn vortarerojn(dum rekonstrui)"
	echo "  -r, --rebuild       rebuild dictionary with specified systems"
	echo "      --rekonstrui    rekonstrui vortaron per difinitaj sistemoj"
	echo "  -x, --xsystem       add X-system entries to dictionary(during rebuild)"
	echo "      --xsistemo      aldoni X-sistemajn vortarerojn(dum rekonstrui)"
	echo ""
	echo "Exit Status(Elira Kodo):"
	echo " 0  if OK"
	echo " 0  se bona"
	echo " 1  if general problem"
	echo " 1  se ĝenerala problemo"
	echo " 2  if serious problem"
	echo " 2  se serioza problemo"
	echo " 64 if programming issue"
	echo " 64 se problemo de programado"
	exit 0
}

build_dictionary() {
	wget -o /dev/null -O "$cache" $espdic_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "Wget of espdic failed" 1>&2
		exit 1
	fi
	# Convert DOS newline to Unix
	sed -i 's/.$//' $cache

	if ($x_system); then
		# Add lines using X-system to dictionary
		sed -i -e '/\xc4\x89\|\xc4\x9d\|\xc4\xb5\|\xc4\xa5\|\xc5\xad\|\xc5\x9d\|\xc4\xa4\|\xc4\x88\|\xc4\x9c\|\xc4\xb4\|\xc5\x9c\|\xc5\xac/{p; s/\xc4\x89/cx/g; s/\xc4\x9d/gx/g; s/\xc4\xb5/jx/g; s/\xc4\xa5/hx/g; s/\xc5\xad/ux/g; s/\xc5\x9d/sx/g; s/\xc4\xa4/HX/g; s/\xc4\x88/CX/g; s/\xc4\x9c/GX/g; s/\xc4\xb4/JX/g; s/\xc5\x9c/SX/g; s/\xc5\xac/UX/g;}' "$cache"
	fi

	if ($h_system); then
		# Add lines using H-system to dictionary
		sed -i -e '/\xc4\x89\|\xc4\x9d\|\xc4\xb5\|\xc4\xa5\|\xc5\xad\|\xc5\x9d\|\xc4\xa4\|\xc4\x88\|\xc4\x9c\|\xc4\xb4\|\xc5\x9c\|\xc5\xac/{p; s/\xc4\x89/ch/g; s/\xc4\x9d/gh/g; s/\xc4\xb5/jh/g; s/\xc4\xa5/hh/g; s/\xc5\xad/u/g; s/\xc5\x9d/sh/g; s/\xc4\xa4/Hh/g; s/\xc4\x88/Ch/g; s/\xc4\x9c/Gh/g; s/\xc4\xb4/Jh/g; s/\xc5\x9c/Sh/g; s/\xc5\xac/U/g;}' "$cache"
	fi
}

rebuild_dictionary() {
	# Remove old dictionary
	rm -f "$cache"
	# Build dictionary
	build_dictionary
}

check_depends() {
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
}

main() {
	check_depends

	# Getopt
	local short=hrx
	local long=hsystem,hsistemo,rebuild,rekonstrui,xsystem,xsistemo,help,helpi

	parsed=$(getopt --options $short --longoptions $long --name "$0" -- "$@")
	if [[ $? != 0 ]]; then
		# Getopt not getting arguments correctly
		exit 2
	fi

	eval set -- "$parsed"

	# Deal with command-line arguments
	while true; do
		case $1 in
			--help|--helpi)
				print_usage
				;;
			-h|--hsystem|--hsistemo)
				h_system=true
				;;
			-r|--rebuild|--rekonstrui)
				rebuild=true
				;;
			-x|--xsystem|--xsistemo)
				x_system=true
				;;
			--)
				shift
				break
				;;
			*)
				# Unknown option
				echo "$2 argument not properly handled"
				exit 64
				;;
		esac
		shift
	done

	if ($rebuild); then
		rebuild_dictionary
	# If ESPDIC is not installed
	elif [ ! -r "$cache" ]; then
		# Assume X-system by default
		x_system=true
		build_dictionary
	else
		cat "$cache" | dmenu -l 10 "$@"
	fi
}

main "$@"
