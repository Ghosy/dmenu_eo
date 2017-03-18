#!/bin/bash

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
fi
