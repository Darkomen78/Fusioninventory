Fusioninventory
==========

Everything you need to use and deploy FusionInventory-agent on OSX 
Tested on 10.8.x / 10.9.X / 10.10.x

**In daemon mode the "Force Inventory" link ( http://127.0.0.1:62354 ) not work well in Safari. Please use Firefox or Chrome to use this link.**

More info at http://www.fusioninventory.org

• Build_Fusioninventory_OSX_Flavor.sh

HowTo build Fusioninventory OSX package :

1. Copy the "Build" script in a folder on your "OSX build machine"
2. Open terminal and type : `cd "path_to_the_script_folder"`
3. Type `./Build_FusionInventory_OSX_Flavor.sh [Version]`
4. Follow script instructions

Major step :

-> Install Xcode command line tools

-> Install Perlbrew

-> Install Perl 5.16.2 in Perlbrew

-> Install CPANM in Perl 5.16.2 (in Perlbrew)

-> Install (say y(es) on first launch) or update modules in Perl 5.16.2 (in Perlbrew)

-> Download FusionInventory-agent [Version] sources from https://cpan.metacpan.org/authors/id/G/GR/GROUSSE/

-> Tweak default agent.cfg for OSX

-> Create "[Version] source folder" with files ready to copy or package

-> Optional Vanilla package : create a simple package for test, after your package install test, duplicate /Library/Preferences/fusioninventory/agent.cfg.default to /Library/Preferences/fusioninventory/agent.cfg and edit it with your settings

-> Optional Deploy package : create an ARD-ready package (with autostart at login) 

-> Optional Configure Deploy Package : edit TAG and server URL for your first deployment package. You can run configure.command later (in Deploy folder) to configure new deploy package
