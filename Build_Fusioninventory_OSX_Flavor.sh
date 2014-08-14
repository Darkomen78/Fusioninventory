#!/bin/bash

# Pour préparer un agent plus récent, remplacer la variable FI_VERSION avec une nouvelle version
FI_VERSION="2.3.10.1"
FI_DIR="fusioninventory-agent-$FI_VERSION"
# Perlbrew settings
PERLBREWROOTDST=~/perl5
OSXPERLVER="5.16.2"

# Chemin d'installation pour la version OSX
INSTALL_PATH='/usr/local/fusioninventory'
CONFDIR_PATH='/Library/Preferences/fusioninventory'
DATADIR_PATH='/usr/local/fusioninventory/share'
# Le répertoire pour les sources à packager
SRCDST="`pwd`/Source"

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
clear
echo "Perlbrew not found, install it"
curl -L http://install.perlbrew.pl | bash
echo "export PERLBREW_HOME=/tmp/.perlbrew" >> ~/.bash_profile
echo "source $PERLBREWROOTDST/perlbrew/etc/bashrc" >> ~/.bash_profile
read -p "Perlbrew install OK, please restart Terminal.app and relaunch this script"
exit 0
fi

if [ ! -f $PERLBREWROOTDST/perlbrew/bin/cpanm ]; then
echo "cpanm in Perlbrew not found, install it"
perlbrew install-cpanm
fi

$PERLBREWROOTDST/perlbrew/bin/cpanm --local-lib=$PERLBREWROOTDST local::lib && eval $(perl -I $PERLBREWROOTDST/lib/perl5/ -Mlocal::lib)

if [[ ! -f $PERLBREWROOTDST/perlbrew/dists/perl-$OSXPERLVER.tar.bz2 ]]; then
echo "OSX Perl current version ($OSXPERLVER) not found, install it"
perlbrew install perl-$OSXPERLVER
perlbrew switch perl-$OSXPERLVER
fi

perlbrew use $OSXPERLVER
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

echo "Pseudo installation dans le dossier sources..."
#perlbrew exec perl Makefile.PL PREFIX="$INSTALL_PATH" SYSCONFDIR="$CONFDIR_PATH" DATADIR="$DATADIR_PATH"
perlbrew exec perl Makefile.PL SYSCONFDIR="$CONFDIR_PATH" DATADIR="$DATADIR_PATH"
perlbrew exec make
perlbrew exec make install PREFIX="$INSTALL_PATH" DESTDIR="$SRCDST"

echo "Add perl dependance"
cpanm --installdeps -L extlib --notest .
rsync -r extlib/lib/perl5/ "$SRCDST$DATADIR_PATH/lib/"