#!/bin/bash

# Ask admin password
(( EUID != 0 )) && exec sudo -- "$0" "$@"

# Cleanup folders populated by build script
rm -rf /usr/local/fusioninventory
rm -rf /usr/local/var/fusioninventory
rm -rf /Library/Preferences/fusioninventory
rm -rf /tmp/FusionInventory-Agent-*
rm -rf /tmp/