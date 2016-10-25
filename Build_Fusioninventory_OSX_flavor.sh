#!/bin/bash

# Original version and 1.4 by Sylvain La Gravière
# Twitter : @darkomen78
# Mail : darkomen@me.com

# Version 1.3 by Thomas Dannenmüller
# Mail : tromatik@gmail.com

# Ask admin password
(( EUID != 0 )) && exec sudo -- "$0" "$@"

# FusionInventory version
FI_VERSION=$1
if [[ $FI_VERSION = [0-2].[0-3].[0-9] || $FI_VERSION = [0-2].[0-3].[0-1][0-8] ]]; then
		echo "Building requested package version: $FI_VERSION"
	else
		echo -e "\nUsage: ""$0"" [version]\nExample : ""$0"" 2.3.17\nAvailable versions : https://github.com/fusioninventory/fusioninventory-agent/releases\n"
		exit 0
fi
TEST_VERSION=$(echo $FI_VERSION | sed  s'/\.//g')

# FusionInventory Agent source
FUSIONSRC="https://github.com/fusioninventory/fusioninventory-agent/archive/"

# Stéphane Sudre's Packages software
PACKAGESSRC="http://s.sudre.free.fr/Software/files/Packages.dmg"

# Darkomen's git stuff
GITSRC="https://raw.github.com/Darkomen78/Fusioninventory/master/source/"

# Automatic Perl version detection
OSXPERLVER=$(perl -v | grep v5 | cut -d "(" -f 2 | cut -d ")" -f 1 | sed s'/v//'g)

# Temporary local source folder
FI_DIR="fusioninventory-agent-$FI_VERSION"

# Temporary Packages files
PROJ="FusionInventory.pkgproj"
DEPLOYPROJ="FusionInventory_deploy.pkgproj"

# Default paths for OSX
INSTALL_PATH='/usr/local/fusioninventory'
CONFDIR_PATH='/Library/Preferences/fusioninventory'
DATADIR_PATH='/usr/local/fusioninventory/share'

# Current dir
ROOTDIR="`pwd`"

# Local final folder
SRCDST="$ROOTDIR/$FI_VERSION/"


# Perlbrew install path and mandatory variables
PERLBREWROOTDST=$INSTALL_PATH
PERLBREW_ROOT=$PERLBREWROOTDST/perlbrew
export PERLBREW_ROOT=$PERLBREWROOTDST/perlbrew
PERLBREW_HOME=/tmp/.perlbrew
if [ -f $PERLBREW_ROOT/etc/bashrc ]; then
	source $PERLBREW_ROOT/etc/bashrc
fi

if [ ! -d /Library/Developer/CommandLineTools ]; then
	#clear
	echo "Xcode command line tools not found, install it..."
	xcode-select --install
	read -p "When Xcode command line tools install is finish, please relaunch this script" -t 5
	echo
	exit 0
fi

if [ ! -d $PERLBREW_ROOT ]; then
	#clear
	echo "Perlbrew not found, install it..."
	curl -L 'http://install.perlbrew.pl' | bash
	read -p "Perlbrew install is OK. Quit and restart Terminal, then relaunch this script" -t 5
	echo
	exit 0
fi

if [ ! -d "$PERLBREW_ROOT"/perls/perl-"$OSXPERLVER" ]; then
	#clear
	echo "Perl $OSXPERLVER in Perlbrew not found, install it..."
	perlbrew install perl-$OSXPERLVER -D usethreads
	read -p "Perl $OSXPERLVER install is finish, please relaunch this script" -t 5
	echo
	exit 0
fi

if [ -d $PERLBREWROOTDST/perlbrew/perls/perl-$OSXPERLVER ]; then
	#clear
	echo "################## Switch to Perl version $OSXPERLVER #######################"
	perlbrew switch "$OSXPERLVER"
fi

if [ ! -f $PERLBREWROOTDST/perlbrew/perls/perl-$OSXPERLVER/bin/cpanm ]; then
	#clear
	echo "cpanm in Perlbrew not found, install it..."
	cpan -i App::cpanminus
fi

read -p "----------------> Update Perl modules... ? [Y] " -n 1 -r UPDMOD
echo
if [[ $UPDMOD =~ ^[Nn]$ ]]; then
	echo "...skip update modules"
else
#	Error or optional IO::Socket::SSL Net::CUPS Net::Write::Layer2 LWP::Protocol::https
	"$PERLBREWROOTDST/perlbrew/perls/perl-$OSXPERLVER/bin/cpanm" -i \
	Archive::Extract \
	Compress::Zlib \
	Config::Tiny \
	Crypt::DES \
	Digest::SHA \
	File::Copy::Recursive \
	File::Which \
	HTTP::Daemon \
	HTTP::Proxy \
	HTTP::Server::Simple::Authen \
	inc::Module::Install \
	IO::Capture::Stderr \
	IPC::Run \
	JSON \
	LWP::UserAgent \
	Net::IP \
	Net::Ping \
	Net::SNMP \
	Parse::EDID \
	POE::Component::Client::Ping \
	POSIX \
	Proc::Daemon \
	Proc::PID::File \
	Socket::GetAddrInfo \
	Test::Compile \
	Test::Deep \
	Test::Exception \
	Test::MockModule \
	Test::MockObject \
	Test::NoWarnings \
	Text::Template \
	Thread::Queue \
	UNIVERSAL::require \
	URI::Escape \
	XML::TreePP \
/
fi

if [ ! -f /tmp/$FI_DIR.tar.gz ]; then
	curl -s -L $FUSIONSRC$FI_VERSION.tar.gz  -o /tmp/$FI_VERSION.tar.gz && echo "Download $FI_DIR"
fi

echo "Empty destination folder"
cd /tmp/
rm -Rf $INSTALL_PATH/bin
rm -Rf $INSTALL_PATH/share
tar xzf $FI_VERSION.tar.gz && rm $FI_VERSION.tar.gz
cd /tmp/$FI_DIR

echo "Temporary install..."
export SYSCONFDIR="$CONFDIR_PATH"
export DATADIR="$DATADIR_PATH"
perl Makefile.PL -I lib SYSCONFDIR="$CONFDIR_PATH" DATADIR="$DATADIR_PATH"
make
make install PREFIX="$INSTALL_PATH"
cpanm --installdeps -L extlib --notest .

echo "Rename default agent.cfg file to use later with OSX package postinstall script"
mv $CONFDIR_PATH/agent.cfg $CONFDIR_PATH/agent.cfg.default
echo "######################################"
echo "Modify agent.cfg.default"
echo "######################################"
echo "Add 127.0.0.1 in httpd-trust"
sed -i "" "s/httpd-trust =/httpd-trust = 127.0.0.1/g" $CONFDIR_PATH/agent.cfg.default
echo "######################################"
echo "Change backend timeout from 30 to 180"
sed -i "" "s/backend-collect-timeout = 30/backend-collect-timeout = 180/g" $CONFDIR_PATH/agent.cfg.default
echo "######################################"
 if (( $TEST_VERSION <= 238 )); then
	echo "######################################"
	echo "Comment scan-profiles option for pre 2.3.8 versions of the agent"
	sed -i "" "s/scan-profiles = 0/#scan-profiles = 0/g" $CONFDIR_PATH/agent.cfg.default
	echo "######################################"
fi

echo "Move files to Source folder for packages..."
if [ ! -d "$SRCDST/Source" ]; then
	mkdir -p "$SRCDST/Source"
else
	read -p "----------------> Use current source folder ? [Y] " -n 1 -r USECURRENTSRC
	if [[ $USECURRENTSRC =~ ^[Nn]$ ]]; then
		if [ -d "$SRCDST/Source_previous" ]; then
			rm -Rf "$SRCDST/Source_previous"
		fi
	echo
	echo "old source move to Source_previous"
	mv "$SRCDST/Source" "$SRCDST/Source_previous"
	mkdir -p "$SRCDST/source"
	fi
fi
cd "$SRCDST/Source"
mkdir -p ."$CONFDIR_PATH"
mkdir -p ."$INSTALL_PATH"

read -p "----------------> Delete temporary files ? [N] " -n 1 -r TEMPFILE
echo
if [[ $TEMPFILE =~ ^[Yy]$ ]]; then
	echo "...remove temporary files"
	rm -Rf /tmp/$FI_DIR
	cp -R "$CONFDIR_PATH/"* ."$CONFDIR_PATH/" && rm -Rf "$CONFDIR_PATH"
	cp -R "$INSTALL_PATH/"* ."$INSTALL_PATH/" && rm -Rf "$INSTALL_PATH"
else
	cp -R "$CONFDIR_PATH/"* ."$CONFDIR_PATH/"
	cp -R "$INSTALL_PATH/"* ."$INSTALL_PATH/"
fi
# Remove heavy useless files
rm -Rf ".$PERLBREW_ROOT/build"
rm -Rf ".$PERLBREW_ROOT/dists"
rm -Rf ".$PERLBREW_ROOT/perls/perl-$OSXPERLVER/man"
chown :admin "$ROOTDIR"
chmod -R 775 "$ROOTDIR"
echo "Files copied in ""$SRCDST""Source/"
echo
read -p "----------------> Create test package ? [Y] " -n 1 -r PKG
echo
if [[ $PKG =~ ^[Nn]$ ]]; then
	echo "...skip create test package"
else
	if [ ! -d "/Applications/Packages.app" ]; then
		echo "No Packages install found, install it..."
		cd /tmp/
		curl -O -L $PACKAGESSRC && echo "Download Stéphane Sudre's Packages install"
		hdiutil mount /tmp/Packages.dmg && echo "Mount Packages install"
		/usr/sbin/installer -dumplog -verbose -pkg "/Volumes/Packages/packages/Packages.pkg" -target / && echo "Install Packages" && hdiutil unmount /Volumes/Packages/ && echo "Unmount Packages install"
	fi
	if [ ! -f "$SRCDST/FusionInventory.pkgproj" ]; then
		echo "FusionInventory.pkgproj not found, download it..."
		cd "$SRCDST"
		curl -O -L "$GITSRC$PROJ"
	fi
	echo "update version on .pkgproj to " $FI_VERSION
	cd "$SRCDST"
	packagesutil --file "FusionInventory.pkgproj" set version $FI_VERSION
	/usr/local/bin/packagesbuild -v "FusionInventory.pkgproj" && rm "FusionInventory.pkgproj"
	chown -R :admin ./build && chmod -R 775 ./build && open ./build
fi
read -p "----------------> Create vanilla deployment package ? [Y] " -n 1 -r DEPLOY
echo
if [[ $DEPLOY =~ ^[Nn]$ ]]; then
	echo "...skip create deployment package"
	echo
	exit 0
else
	if [ ! -d "/Applications/Packages.app" ]; then
		echo "No Packages install found, install it..."
		cd /tmp/
		curl -O -L $PACKAGESSRC && echo "Download Stéphane Sudre's Packages install"
		hdiutil mount /tmp/Packages.dmg && echo "Mount Packages install"
		/usr/sbin/installer -dumplog -verbose -pkg "/Volumes/Packages/packages/Packages.pkg" -target / && echo "Install Packages" && hdiutil unmount /Volumes/Packages/ && echo "Unmount Packages install"
	fi
	if [ ! -f "$SRCDST/FusionInventory_deploy.pkgproj" ]; then
		echo "FusionInventory_deploy.pkgproj not found, download it..."
		cd "$SRCDST"
		curl -O -L "$GITSRC$DEPLOYPROJ"
	fi
	if [ ! -d "$SRCDST/Deploy" ]; then
		cd "$SRCDST"
		curl -O -L "$GITSRC"Deploy.zip
		unzip "Deploy.zip" && rm "Deploy.zip" && rm -R ./__MACOSX
	fi
	if [ ! -d "$SRCDST/source_deploy" ]; then
		cd "$SRCDST"
		curl -O -L "$GITSRC"source_deploy.zip
		unzip "source_deploy.zip" && rm "source_deploy.zip" && rm -R ./__MACOSX
	fi
	cd "$SRCDST"
	echo "update version on .pkgproj to " $FI_VERSION
	packagesutil --file "FusionInventory_deploy.pkgproj" set package-2 version $FI_VERSION
	/usr/local/bin/packagesbuild -v "FusionInventory_deploy.pkgproj" && rm -R ./source_deploy && rm "FusionInventory_deploy.pkgproj"
	chown -R :admin ./Deploy && chmod -R 775 ./Deploy && open ./Deploy
	read -p "----------------> Configure your first deployment package ? [Y] " -n 1 -r CONF
	echo
	if [[ $CONF =~ ^[Nn]$ ]]; then
		echo "...skip configure deployment package"
		echo
		exit 0
	else
		open "$SRCDST/Deploy/Configure.command"
	fi
fi
echo
exit 0
