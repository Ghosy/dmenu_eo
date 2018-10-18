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
rebuild=false
quiet=false
silent=false
dmenu=""
# Get default system languae as default locale setting
locale=$(locale | grep "LANG" | cut -d= -f2 | cut -d_ -f1)
# ESPDIC download location
espdic_dl="http://www.denisowski.org/Esperanto/ESPDIC/espdic.txt"
oconnor_hayes_dl="http://www.gutenberg.org/files/16967/16967-0.txt"
komputeko_dl="https://komputeko.net/Komputeko-ENEO.pdf"
vikipedio_search="https://eo.wikipedia.org/w/api.php?action=opensearch&search="

# cache from dmenu_path
cachedir=${XDG_CACHE_HOME:-"$HOME/.cache"}
cachedir="$cachedir/dmenu_eo"

# Check cache dir and create if missing
mkdir -p "$cachedir"

espdic_cache=$cachedir/espdic
oconnor_hayes_cache=$cachedir/oconnor_hayes
komputeko_cache=$cachedir/komputeko

dicts=("$espdic_cache" "$oconnor_hayes_cache" "$komputeko_cache")

menu_choices="ESPDIC\\nO'Connor And Hayes\\nKomputeko\\nVikipedio";

# Set default dictionary
choice=""

print_usage() {
	echo "Usage: dmenu_eo [OPTION]..."
	echo "Options(Agordoj):"
	echo "  -d, --dict=DICT       the DICT to be browsed(options below)"
	echo "      --vortaro=DICT    la DICT foliota(elektoj malsupre)"
	echo "      --en              display all messages in English"
	echo "                        prezenti ĉiujn mesaĝojn angle"
	echo "      --eo              display all messages in Esperanto"
	echo "                        prezenti ĉiujn mesaĝojn Esperante"
	echo "      --help            display this help message"
	echo "      --helpi           prezenti ĉi tiun mesaĝon de helpo"
	echo "  -h, --hsystem         add H-system entries to dictionary(during rebuild)"
	echo "      --hsistemo        aldoni H-sistemajn vortarerojn(dum rekonstrui)"
	echo "  -m, --menu            select dictionary to browse from a menu"
	echo "      --menuo           elekti vortaron por folii per menuo"
	echo "  -q, --quiet           suppress all messages, except error messages"
	echo "      --mallaŭta        kaŝi ĉiujn mesaĝojn, krom eraraj mesaĝoj"
	echo "  -r, --rebuild         rebuild dictionary with specified systems"
	echo "      --rekonstrui      rekonstrui vortaron per difinitaj sistemoj"
	echo "      --rofi            override the default and use rofi instead of dmenu"
	echo "                        transpasi la defaŭlto kaj uzi rofi anstataŭ dmenu"
	echo "      --silent          supress all messages"
	echo "      --silenta         kaŝi ĉiujn mesaĝojn"
	echo "      --version         show the version information for dmenu_eo"
	echo "      --versio          elmontri la versia informacio de dmenu_eo"
	echo "  -x, --xsystem         add X-system entries to dictionary(during rebuild)"
	echo "      --xsistemo        aldoni X-sistemajn vortarerojn(dum rekonstrui)"
	echo ""
	echo "Dictionaries(Vortaroj):"
	echo "  ES: ESPDIC"
	echo "  OC: O'Connor and Hayes Dictionary"
	echo "  KO: Komputeko"
	echo "  VI: Vikipedio"
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

print_version() {
	echo "dmenu_eo, version 0.1"
	echo "Copyright (C) 2016-2018 Zachary Matthews"
	echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
	echo ""
	echo "This is free software; you are free to change and redistribute it."
	echo "There is NO WARRANTY, to the extent permitted by law."
	exit 0
}

print_err() {
	if (! $silent); then
		# If enough parameters and locale is eo, else use en
		if [ "$#" -gt "1" ] && [[ "$locale" == "eo" ]]; then
			echo "$2" 1>&2
		else
			echo "$1" 1>&2
		fi
	fi
}

build_dictionary() {
	# Get ESPDIC
	wget -o /dev/null -O "$espdic_cache" $espdic_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		print_err "Wget of ESPDIC failed." "Wget de ESPDIC paneis."
		exit 1
	fi
	# Get O'Connor/Hayes
	wget -o /dev/null -O "$oconnor_hayes_cache" $oconnor_hayes_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		print_err "Wget of O'Connor and Hayes dictionary failed." "Wget de O'Connor kaj Hayes vortaro paneis."
		exit 1
	fi
	wget -o /dev/null -O "$komputeko_cache.pdf" $komputeko_dl >> /dev/null
	if [ "$?" -ne 0 ]; then
		print_err "Wget of Komputeko failed." "Wget de Komputeko paneis."
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
	# Remove extra .'s
	sed -ri 's/(\.|\. \[.+)$//g' "$oconnor_hayes_cache"

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

	for dict in "${dicts[@]}"; do

		if ($x_system); then
			# Add lines using X-system to dictionary
			sed -i -e '/\xc4\x89\|\xc4\x9d\|\xc4\xb5\|\xc4\xa5\|\xc5\xad\|\xc5\x9d\|\xc4\xa4\|\xc4\x88\|\xc4\x9c\|\xc4\xb4\|\xc5\x9c\|\xc5\xac/{p; s/\xc4\x89/cx/g; s/\xc4\x9d/gx/g; s/\xc4\xb5/jx/g; s/\xc4\xa5/hx/g; s/\xc5\xad/ux/g; s/\xc5\x9d/sx/g; s/\xc4\xa4/HX/g; s/\xc4\x88/CX/g; s/\xc4\x9c/GX/g; s/\xc4\xb4/JX/g; s/\xc5\x9c/SX/g; s/\xc5\xac/UX/g;}' "$dict"

		fi

		if ($h_system); then
			# Add lines using H-system to dictionary
			sed -i -e '/\xc4\x89\|\xc4\x9d\|\xc4\xb5\|\xc4\xa5\|\xc5\xad\|\xc5\x9d\|\xc4\xa4\|\xc4\x88\|\xc4\x9c\|\xc4\xb4\|\xc5\x9c\|\xc5\xac/{p; s/\xc4\x89/ch/g; s/\xc4\x9d/gh/g; s/\xc4\xb5/jh/g; s/\xc4\xa5/hh/g; s/\xc5\xad/u/g; s/\xc5\x9d/sh/g; s/\xc4\xa4/Hh/g; s/\xc4\x88/Ch/g; s/\xc4\x9c/Gh/g; s/\xc4\xb4/Jh/g; s/\xc5\x9c/Sh/g; s/\xc5\xac/U/g;}' "$dict"

		fi
	done
}

rebuild_dictionary() {
	# Remove old dictionaries
	for dict in ${dicts[*]}; do
		rm -f "$dict"
	done
	# Build dictionary
	build_dictionary
	exit 0
}

check_depends() {
	# Check for wget
	if ! type wget >> /dev/null; then
		print_err "Wget is not installed. Please install wget." "Wget ne estas instalita. Bonvolu instali wget."
		exit 1
	fi
	# Check for dmenu or rofi
	if type dmenu >> /dev/null; then
		dmenu="dmenu"
	elif type rofi >> /dev/null; then
		dmenu="rofi -dmenu"
	else
		print_err "Dmenu is not installed. Please install dmenu." "Dmenu ne estas instalita. Bonvolu instali dmenu."
		exit 1
	fi
}

search_vikipedio() {
	if ! type jq >>/dev/null; then
		print_err "Jq is not installed. Please install jq to use Vikipedio." "Jq ne estas instalita. Bonvolu instali jq por uzi Vikipedion."
		exit 1
	fi

	cmd="$dmenu -p \"Vikipedio:\" < /dev/null"
	input=$(eval "$cmd")
	declare -A results
	IFS=$'\n'
	search=$(wget -o /dev/null -O - "$vikipedio_search$input")
	# Get array of search results with corresponding URLs
	mapfile -t keys < <(jq -r '.[1]|join("\n")' <<< "$search")
	mapfile -t vals < <(jq -r '.[3]|join("\n")' <<< "$search")

	for ((i=0; i < ${#keys[*]}; i++)); do
		results["${keys[i]}"]=${vals[i]}
	done

	cmd="$dmenu -l 10 <<< \"${keys[*]}\""
	xdg-open "${results[$(eval "$cmd")]}"
}

get_choice() {
	if [ ! -z "$choice" ]; then
		print_err "A dictionary option has already been chosen. Only use one flag of -m or -d." "Elekto de vortaro jam elektis. Nur uzu unu flagon de -m aŭ -d."
		exit 1
	fi
	case ${1^^} in
		ES|ESPDIC)
			choice="$espdic_cache"
			;;
		OC|O\'CONNOR\ AND\ HAYES)
			choice="$oconnor_hayes_cache"
			;;
		KO|KOMPUTEKO)
			choice="$komputeko_cache"
			;;
		VI|VIKIPEDIO)
			search_vikipedio
			exit 0
			;;
		"")
			# If escape is pressed, quit
			exit 0
			;;
		*)
			print_err "$1 is not a valid option for a dictionary." "$1 ne estas valida elekto por vortaro."

			exit 1;
			;;
	esac
}

main() {
	check_depends

	# Getopt
	local short=d:hmqrx
	local long=dict:,en,eo,vortaro:,hsystem,hsistemo,menu,menuo,quiet,mallauxta,mallauta,mallaŭta,rebuild,rekonstrui,rofi,silent,silenta,xsystem,xsistemo,help,helpi,version,versio

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
			--en)
				locale="en"
				;;
			--eo)
				locale="eo"
				;;
			--help|--helpi)
				print_usage
				;;
			-h|--hsystem|--hsistemo)
				h_system=true
				;;
			-m|--menu|--menuo)
				cmd=$(echo -e "$dmenu -i -l 10 <<< \"$menu_choices\"")
				get_choice "$(eval "$cmd")"
				;;
			-q|--quiet|--mallauxta|--mallauta|--mallaŭta)
				quiet=true
				;;
			-r|--rebuild|--rekonstrui)
				# rebuild_dictionary
				rebuild=true
				;;
			--rofi)
				if ! type rofi >> /dev/null; then
					print_err "Rofi is not installed. Please install rofi to use --rofi." "Rofi ne estas instalita. Bonvolu instali rofi por uzi --rofi."
					exit 1
				fi
				dmenu="rofi -dmenu"
				;;
			--silent|--silenta)
				silent=true
				;;
			--version|--versio)
				print_version
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
				print_err "$1 argument not properly handled." "$1 argumento ne prave uzis."
				exit 64
				;;
		esac
		shift
	done

	if ($rebuild); then
		rebuild_dictionary
	fi
	# If any dictionaries aren't installed
	for dict in "${dicts[@]}"; do
		if [ ! -r "$dict" ]; then
			# Assume X-system by default
			x_system=true
			build_dictionary
		fi
	done

	# If no dictionary has been selected
	if [ -z "$choice" ]; then
		choice="$espdic_cache"
	fi
	# Display dictionary
	cmd="$dmenu -l 10 < \"$choice\" >> /dev/null"
	eval "$cmd"
}

main "$@"
