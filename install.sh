#!/bin/bash
#
# This program allows the installation of dmenu_eo
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

if [[ $EUID -ne 0 ]]; then
	echo "You must be root to perform this action" 1>&2
	exit 1
else
	printf "Installing dmenu_eo... "
	# Install bin
	install -Dm 755 "dmenu_eo.sh" "/usr/local/bin/dmenu_eo"

	printf "Complete\\n"

	printf "Installing dmenu_eo completions... "
	install -Dm 644 "doc/dmenu_eo.bashcomp" "/usr/share/bash-completion/completions/dmenu_eo"
	printf "Complete\\n"

	printf "Installing manpages... "
	# Install en manpage
	install -Dm 644 "doc/dmenu_eo.1" "/usr/local/share/man/man1"
	gzip -fq "/usr/local/share/man/man1/dmenu_eo.1"

	# Install eo manpage
	install -Dm 644 "doc/eo.dmenu_eo.1" "/usr/local/share/man/eo/man1/dmenu_eo.1"
	gzip -fq "/usr/local/share/man/eo/man1/dmenu_eo.1"

	printf "Complete\\n"

	printf "Updating manpage database... "
	# Update manpages database
	mandb -q
	printf "Complete\\n"

	echo "Install success"
fi
