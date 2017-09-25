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
	# Add to /bin/
	cp dmenu_eo.sh /usr/local/bin/dmenu_eo

	# Set permissions
	chmod 755 "/usr/local/bin/dmenu_eo"

	# Change owner
	chown root "/usr/local/bin/dmenu_eo"

	echo "Install success"
fi
