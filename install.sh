#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "You must be root to perform this action" 2>&1
	exit 1
else
	# Set permissions
	chmod 755 "dmenu_eo.sh"

	# Change owner
	chown root "dmenu_eo.sh"

	# Add to /bin/
	cp dmenu_eo.sh /bin/dmenu_eo
fi
