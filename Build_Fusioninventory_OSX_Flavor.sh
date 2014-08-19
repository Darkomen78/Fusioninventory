#!/bin/bash

# Pour préparer un agent plus récent, remplacer la variable FI_VERSION avec une nouvelle version
FI_VERSION="2.3.10.1"
FI_DIR="fusioninventory-agent-$FI_VERSION"
# Perlbrew settings
PERLBREWROOTDST=$HOME/perl5
OSXPERLVER="5.16.2"

# Chemin d'installation pour la version OSX
INSTALL_PATH='/usr/local/fusioninventory'
CONFDIR_PATH='/Library/Preferences/fusioninventory'
DATADIR_PATH='/usr/local/fusioninventory/share'
# Le répertoire pour les sources à packager
ROOTDIR="`pwd`"
SRCDST=$ROOTDIR"/Source"

export PERLBREW_ROOT=$PERLBREWROOTDST/perlbrew
export PERLBREW_HOME=/tmp/.perlbrew
source ${PERLBREW_ROOT}/etc/bashrc

if [ ! -d /Library/Developer/CommandLineTools ]; then
clear
echo "No Xcode command line tools found, ask to install it"
xcode-select --install
read -p "When Xcode command line tools install is finish, relaunch this script"
exit 0
fi

if [ ! -d $PERLBREWROOTDST ]; then
echo "Perlbrew not found, install it"
curl -L http://install.perlbrew.pl | bash
echo 'export PERLBREW_HOME=/tmp/.perlbrew' >> ~/.bash_profile
echo 'source $PERLBREWROOTDST/perlbrew/etc/bashrc' >> ~/.bash_profile
read -p "Perlbrew install OK, please restart Terminal.app and relaunch this script"
exit 0
fi

if [[ ! -f $PERLBREWROOTDST/perlbrew/bin/cpanm ]]; then
echo "cpanm in Perlbrew not found, install it"
perlbrew install-cpanm
fi

$PERLBREWROOTDST/perlbrew/bin/cpanm --local-lib=$PERLBREWROOTDST local::lib && eval $(perl -I $PERLBREWROOTDST/lib/perl5/ -Mlocal::lib)

# Installe les modules manquants
echo "install or update required Perl modules"
cpanm -i Module::Install ExtUtils::MakeMaker HTTP::Proxy HTTP::Server::Simple HTTP::Server::Simple::Authen IO::Capture::Stderr IO::Socket::SSL IPC::Run JSON LWP::Protocol::https Net::SNMP POE::Component::Client::Ping Test::Compile Test::Deep Test::Exception Test::HTTP::Server::Simple Test::MockModule Test::MockObject Test::More Test::NoWarnings File::Remove File::Which LWP Net::IP Socket::GetAddrInfo Text::Template UNIVERSAL::require XML::TreePP

if [ ! -f $FI_VERSION.tar.gz ]; then
   curl -O -L https://github.com/fusinv/fusioninventory-agent/archive/$FI_VERSION.tar.gz && echo "Téléchargement de l'archive"
fi

echo "Vide le dossier des sources"
rm -Rf $SRCDST
echo "Décompresse l'archive"
tar xzf $FI_VERSION.tar.gz
[ -d "$SRCDST" ] || mkdir "$SRCDST"
cd $FI_DIR

echo "Fake install in destination folder..."
perl Makefile.PL SYSCONFDIR="$CONFDIR_PATH" DATADIR="$DATADIR_PATH"
make
make install PREFIX="$INSTALL_PATH" DESTDIR="$SRCDST"

echo "Add library dependances in the fak install"
cpanm --installdeps -L extlib --notest .
rsync -r extlib/lib/perl5/ "$SRCDST$DATADIR_PATH/lib/"

echo "Rename default agent.cfg file to use later with OSX package postinstall script"
mv $SRCDST$CONFDIR_PATH/agent.cfg $SRCDST$CONFDIR_PATH/agent.cfg.default
#rm -Rf $ROOTDIR/$FI_DIR
echo "######################################"
echo "Modify agent.cfg.default"
echo "######################################"
echo "Add 127.0.0.1 in httpd-trust"
sed -i "" "s/httpd-trust =/httpd-trust = 127.0.0.1/g" $SRCDST$CONFDIR_PATH/agent.cfg.default
echo "######################################"
echo "Change backend timeout from 30 to 180"
sed -i "" "s/backend-collect-timeout = 30/backend-collect-timeout = 180/g" $SRCDST$CONFDIR_PATH/agent.cfg.default
echo "######################################"

