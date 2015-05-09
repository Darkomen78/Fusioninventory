#!/bin/bash

binpath="/usr/local/fusioninventory/bin/"

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
            test -f $binpath/fusioninventory-agent && echo $($binpath/fusioninventory-agent -v) || echo "fusioninventory-agent : not installed"
            test -f $binpath/fusioninventory-netinventory && echo $($binpath/fusioninventory-netinventory --version) || echo "fusioninventory-agent : not installed"
            test -f $binpath/fusioninventory-netdiscovery && echo $($binpath/fusioninventory-netdiscovery --version) || echo "fusioninventory-netdiscovery : not installed"
            test -f $binpath/fusioninventory-esx && echo $($binpath/fusioninventory-esx --version) || echo "fusioninventory-esx : not installed"
            test -f $binpath/fusioninventory-wakeonlan && echo $($binpath/fusioninventory-wakeonlan --version) || echo "fusioninventory-wakeonlan : not installed"
            ;;
        *)
            echo $"Usage: $0 {clean|uninstall|probe}"
            exit 1
esac