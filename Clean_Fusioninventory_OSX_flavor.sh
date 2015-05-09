#!/bin/bash

# Ask admin password
(( EUID != 0 )) && exec sudo -- "$0" "$@"

case "$1" in
        clean)
        	read -p "This will break agent if installed. Proceed? [Y] " doclean
			if [[ $doclean =~ ^[Nn]$ ]]; then
				echo "Cleanup aborted..."
        	else
				rm -rf /usr/local/fusioninventory
				rm -rf /Library/Preferences/fusioninventory
				rm -rf /tmp/FusionInventory-Agent-*
				rm -rf /tmp/extlib
				echo "Build junks deleted !!!"
			fi	
            ;;
         
        uninstall)
            # Cleanup folders populated by build script
			rm -rf /usr/local/fusioninventory
			rm -rf /usr/local/var/fusioninventory
			rm -rf /Library/Preferences/fusioninventory
			rm -rf /tmp/FusionInventory-Agent-*
			rm -rf /tmp/extlib
			rm -f /Library/LaunchDaemons/org.fusioninventory.startup.plist
			echo "Fusioninventory-agent successfully deleted !!!"
            ;;
         
        probe)
            echo $(/usr/local/fusioninventory/bin/fusioninventory-agent -v)
            echo $(/usr/local/fusioninventory/bin/fusioninventory-netinventory --version)
            echo $(/usr/local/fusioninventory/bin/fusioninventory-netdiscovery --version)
            echo $(/usr/local/fusioninventory/bin/fusioninventory-esx --version)
            echo $(/usr/local/fusioninventory/bin/fusioninventory-wakeonlan --version)
            #echo $(/usr/local/fusioninventory/bin/fusioninventory-injector --version)
            ;;
        *)
            echo $"Usage: $0 {clean|uninstall|probe}"
            exit 1
esac