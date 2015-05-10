#!/bin/bash

fipath="/usr/local/fusioninventory"
binpath="$fipath/bin"
confpath="/Library/Preferences"
tmppath="/tmp"
logpath="/usr/local/var/fusioninventory"


# Ask admin password
(( EUID != 0 )) && exec sudo -- "$0" "$@"

case "$1" in
        clean)
        	read -p "This will break agent if installed. Proceed? [Y] " doclean
			if [[ $doclean =~ ^[Nn]$ ]]; then
				echo "Cleanup aborted..."
        	else
				test -d $fipath && rm -rf $fipath && echo "Build junks deleted !!!" || echo "No build junks to clean..."
				test -d $confpath/fusioninventory && rm -rf $confpath/fusioninventory && echo "Agent.conf junks deleted !!!" || echo "No Agent.conf to clean..."
				test -d $tmppath/FusionInventory-Agent-* && rm -rf $tmppath/FusionInventory-Agent-* && echo "Archives junks deleted !!!" || echo "No archives junks to clean..."
				test -f $tmppath/extlib && rm -rf $tmppath/extlib && echo "Extlib junks deleted !!!" || echo "No extlib junks to clean..."
			fi
            ;;
         
        uninstall)
            # Cleanup folders populated by build script
			test -d $fipath && rm -rf $fipath && echo "Agent deleted !!!" || echo "No bins to uninstall..."
			test -d $logpath && rm -rf $logpath && echo "Logs deleted !!!" || echo "No logs to uninstall..."
			test -d $confpath/fusioninventory && rm -rf $confpath/fusioninventory && echo "Agent.conf deleted !!!" || echo "No Agent.conf to uninstall..."
			test -f /Library/LaunchDaemons/org.fusioninventory.startup.plist && rm -f /Library/LaunchDaemons/org.fusioninventory.startup.plist && echo "Daemon plist deleted !!!" || echo "No daemon plist to uninstall..."
            ;;
         
        probe)
        	# Check agent & task bins versions
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
