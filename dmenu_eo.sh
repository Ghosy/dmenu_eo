#!/usr/bin/env bash
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
menu=false
# ESPDIC download location
espdic_dl="http://www.denisowski.org/Esperanto/ESPDIC/espdic.txt"
oconnor_hayes_dl="http://www.gutenberg.org/files/16967/16967-0.txt"
komputeko_dl="https://komputeko.net/Komputeko-ENEO.pdf"

# cache from dmenu_path
cachedir=${XDG_CACHE_HOME:-"$HOME/.cache"}
cachedir="$cachedir/dmenu_eo"

# Check cache dir and create if missing
mkdir -p "$cachedir"

espdic_cache=$cachedir/espdic
oconnor_hayes_cache=$cachedir/oconnor_hayes
komputeko_cache=$cachedir/komputeko

# Set default dictionary
choice="$espdic_cache"

print_usage() {
	echo "Usage: dmenu_eo [OPTION]..."
	echo "Options(Agordoj):"
	echo "  -d, --dict=DICT       the DICT to be browsed(options below)"
	echo "      --vortaro=DICT    la DICT foliota(elektoj malsupre)"
	echo "      --help            display this help message"
	echo "      --helpi           prezenti ĉi tiun mesaĝon de helpo"
	echo "  -h, --hsystem         add H-system entries to dictionary(during rebuild)"
	echo "      --hsistemo        aldoni H-sistemajn vortarerojn(dum rekonstrui)"
	echo "  -m, --menu            select dictionary to browse from a menu"
	echo "      --menuo           elekti vortaron por folii per menuo"
	echo "  -r, --rebuild         rebuild dictionary with specified systems"
	echo "      --rekonstrui      rekonstrui vortaron per difinitaj sistemoj"
	echo "  -x, --xsystem         add X-system entries to dictionary(during rebuild)"
	echo "      --xsistemo      aldoni X-sistemajn vortarerojn(dum rekonstrui)"
	echo ""
	echo "Dictionaries(Vortaroj):"
	echo "  ES: ESPDIC"
	echo "  OC: O'Connor and Hayes Dictionary"
	echo "  KO: Komputeko"
	echo ""
	echo "Exit Status(Elira Kodo):"
	echo "  0  if OK"
	echo "  0  se bona"
	echo "  1  if general problem"
	echo "  1  se ĝenerala problemo"
	echo "  2  if serious problem"
	echo "  2  se serioza problemo"
	echo "  64 if programming issue"
	echo "  64 se problemo de programado"
	exit 0
}

build_dictionary() {
	# Get ESPDIC
	wget -o /dev/null -O "$espdic_cache" $espdic_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "Wget of ESPDIC failed" 1>&2
		exit 1
	fi
	# Get O'Connor/Hayes
	wget -o /dev/null -O "$oconnor_hayes_cache" $oconnor_hayes_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "Wget of O'Connor and Hayes dictionary failed" 1>&2
		exit 1
	fi
	wget -o /dev/null -O "$komputeko_cache.pdf" $komputeko_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "Wget of Komputeko dictionary failed" 1>&2
		exit 1
	fi
	# Convert DOS newline to Unix
	sed -i 's/.$//' "$espdic_cache" "$oconnor_hayes_cache"

	# Clean O'Connor/Hayes preamble
	sed -i '/= A =/,$!d' "$oconnor_hayes_cache"
	# Clean O'Connor/Hayes after dictionary
	sed -i '/\*/,$d' "$oconnor_hayes_cache"
	# Clear extra lines
	sed -i '/^\s*$/d' "$oconnor_hayes_cache"

	# Convert Komputeko to text
	pdftotext -layout "$komputeko_cache.pdf" "$komputeko_cache"
	# Remove pdf
	rm "$komputeko_cache.pdf"
	# Clear Formatting lines
	sed -ri '/(^\s|^$)/d' "$komputeko_cache"
	# Clear Header
	sed -i '/^EN/d' "$komputeko_cache"
	# Replace first multispace per line with : 
	sed -ri 's/ {2,}/: /' "$komputeko_cache"
	# Replace remaining multispace per line with , 
	sed -ri 's/ {2,}/, /' "$komputeko_cache"

	if ($x_system); then
		# Add lines using X-system to dictionary
		sed -i -e '/\xc4\x89\|\xc4\x9d\|\xc4\xb5\|\xc4\xa5\|\xc5\xad\|\xc5\x9d\|\xc4\xa4\|\xc4\x88\|\xc4\x9c\|\xc4\xb4\|\xc5\x9c\|\xc5\xac/{p; s/\xc4\x89/cx/g; s/\xc4\x9d/gx/g; s/\xc4\xb5/jx/g; s/\xc4\xa5/hx/g; s/\xc5\xad/ux/g; s/\xc5\x9d/sx/g; s/\xc4\xa4/HX/g; s/\xc4\x88/CX/g; s/\xc4\x9c/GX/g; s/\xc4\xb4/JX/g; s/\xc5\x9c/SX/g; s/\xc5\xac/UX/g;}' "$espdic_cache" "$oconnor_hayes_cache" "$komputeko_cache"

	fi

	if ($h_system); then
		# Add lines using H-system to dictionary
		sed -i -e '/\xc4\x89\|\xc4\x9d\|\xc4\xb5\|\xc4\xa5\|\xc5\xad\|\xc5\x9d\|\xc4\xa4\|\xc4\x88\|\xc4\x9c\|\xc4\xb4\|\xc5\x9c\|\xc5\xac/{p; s/\xc4\x89/ch/g; s/\xc4\x9d/gh/g; s/\xc4\xb5/jh/g; s/\xc4\xa5/hh/g; s/\xc5\xad/u/g; s/\xc5\x9d/sh/g; s/\xc4\xa4/Hh/g; s/\xc4\x88/Ch/g; s/\xc4\x9c/Gh/g; s/\xc4\xb4/Jh/g; s/\xc5\x9c/Sh/g; s/\xc5\xac/U/g;}' "$espdic_cache" "$oconnor_hayes_cache" "$komputeko_cache"

	fi
}

rebuild_dictionary() {
	# Remove old dictionary
	rm -f "$espdic_cache" "$oconnor_hayes_cache" "$komputeko_cache"
	# Build dictionary
	build_dictionary
	exit 0
}

check_depends() {
	# Check for wget
	if ! type wget >>/dev/null; then
		echo "Wget is not installed. Please install wget." 1>&2
		exit 1
	fi
	# Check for dmenu
	if ! type dmenu >>/dev/null; then
		echo "Dmenu is not installed. Please install dmenu." 1>&2
		exit 1
	fi
}

get_choice() {
	case ${1^^} in
		ES)
			choice="$espdic_cache"
			;;
		OC)
			choice="$oconnor_hayes_cache"
			;;
		KO)
			choice="$komputeko_cache"
			;;
		*)
			echo "$1 is not a valid option for a dictionary" 1>&2

			exit 1;
			;;
	esac
	# Return choice
	echo "$choice" >> /dev/null
}

main() {
	check_depends

	# Getopt
	local short=d:hmrx
	local long=dict:,vortaro:,hsystem,hsistemo,menu,menuo,rebuild,rekonstrui,xsystem,xsistemo,help,helpi

	parsed=$(getopt --options $short --longoptions $long --name "$0" -- "$@")
	if [[ $? != 0 ]]; then
		# Getopt not getting arguments correctly
		exit 2
	fi

	eval set -- "$parsed"

	# Deal with command-line arguments
	while true; do
		case $1 in
			-d|--dict|--vortaro)
				get_choice "$2"
				shift
				;;
			--help|--helpi)
				print_usage
				;;
			-h|--hsystem|--hsistemo)
				h_system=true
				;;
			-m|--menu|--menuo)
				menu=true
				;;
			-r|--rebuild|--rekonstrui)
				rebuild_dictionary
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

	# If ESPDIC is not installed
	if [ ! -r "$espdic_cache" ] && [ ! -r "$oconnor_hayes_cache" ]; then
		# Assume X-system by default
		x_system=true
		build_dictionary
	else
		if ($menu); then
			choice="$cachedir/$(ls "$cachedir" | dmenu -l 10)"
		fi

		# Display dictionary
		dmenu -l 10 < "$choice" >> /dev/null
	fi
}

main "$@"
