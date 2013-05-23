#!/bin/sh
# -*- coding: utf-8 -*-
#
# Description:
#   A post-installation bash script for openSUSE 12.3
#
# Authors : MDVAurelien (Aurélien Sallé) <android.aurelien.salle@gmail.com>
# 
# openSUSE-post-install is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# openSUSE_post_install is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


RELEASE='12.3' # Do not modify this variable, it's use by repositories URL
VERSION='0.8' # It's the version of this file
LICENSE='LGPL'

clear
echo ''
echo '-------------------------------------------'
echo '     openSUSE post installation script     '
echo '-------------------------------------------'

# Are you root ?
if [ "$UID" -ne 0 ]; then
  echo 'You must be root to execute this script'
  exit 10
fi

# Use zypper global-options here
ZYPPER='zypper --no-cd'

# Create and move on a tmp dir
move_tmp_dir() {
TMP_DIR='/tmp/openSUSE-post-install'
if [ -e $TMP_DIR ]; then
  mkdir -p $TMP_DIR
fi
cd $TMP_DIR
}

# Update Repository Information and update the system (with libzypp)
system_upgrade() {
 echo 'Updating repositories information...'
 $ZYPPER refresh
 echo 'Performing system upgrade...'
 $ZYPPER update
 echo 'Done.'
 main
}

# Just apply the needed patches
system_patch() {
 echo 'Cheking path ...'
 $ZYPPER patch
 echo 'Done.'
 main
}

# Install official community repositories (you can put here other official repositories)
install_official_com_repo() {
 echo 'Installing and refresh official community repositories ...'

 # openSUSE BuildService - Games
 zypper lr -u | grep -i "http://download.opensuse.org/repositories/games/openSUSE_$RELEASE" 
 if [ $? -ne 0 ]; then
   echo 'Add official community repositories Games'
   zypper addrepo -f "http://download.opensuse.org/repositories/games/openSUSE_$RELEASE/" "openSUSE BuildService - Games" # for example, here you can get openarena
   echo 'Done.'
 fi
 
 # Packman Repository
 zypper lr -u | grep -i "http://ftp.gwdg.de/pub/linux/packman/suse/openSUSE_$RELEASE" 
 if [ $? -ne 0 ]; then
   echo 'Add Packman Repository'
   zypper addrepo -f "http://ftp.gwdg.de/pub/linux/packman/suse/openSUSE_$RELEASE/" "Packman Repository"
   echo 'Done.'
 fi
 main
}

# Install unofficial community repositories (you can put here other unofficial repositories)
install_unofficial_com_repo() {
 echo 'Installing and refresh unofficial community repositories ...'

 # Lazy Kent
 zypper lr -u | grep -i "http://download.opensuse.org/repositories/home:/Lazy_Kent/openSUSE_$RELEASE/" 
 if [ $? -ne 0 ]; then
   echo 'Add Lazy Kent repositories'
   zypper addrepo -f "http://download.opensuse.org/repositories/home:/Lazy_Kent/openSUSE_$RELEASE/" "Lazy Kent" # for example, here you can get keepassx
   echo 'Done.'
 fi
 
 # VLC official
 zypper lr -u | grep -i "http://download.videolan.org/pub/vlc/SuSE/$RELEASE"
 if [ $? -ne 0 ]; then
   echo 'Add VLC repositories'
   zypper addrepo -f "http://download.videolan.org/pub/vlc/SuSE/$RELEASE/" "VLC"
   echo 'Done.'
 fi
 
 # Strahlex
 zypper lr -u | grep -i "http://download.opensuse.org/repositories/home:/Strahlex/openSUSE_$RELEASE/"
 if [ $? -ne 0 ]; then
   echo 'Add Strahlex repositories'
   zypper addrepo -f "http://download.opensuse.org/repositories/home:/Strahlex/openSUSE_$RELEASE/" "Strahlex" # for example, here you can get unetbootin
   echo 'Done.'
 fi
 main
}

# It's will install your favourite applications (of course, the list is not exhaustive, you can put here your favourites applications)
install_favorite_applications() {
 echo 'Installing selected favourite applications...'
 $ZYPPER install audacity \
                 calibre \
                 chromium \
                 dropbox \
                 filezilla \
                 grsync \
                 inkscape \
                 MozillaThunderbird
 echo 'Done.'
 main
}

# Install system tools (you can put here your favourites system tools applications)
install_system_tools() {
 echo 'Installing system tools...'
 $ZYPPER install htop \
                 nmap \
                 p7zip \
                 wireshark \
                 zsync
 echo 'Done.'
 main
}

# Install various servers and control them with yast2
install_various_servers() {
 INPUT=0
 echo ''
 echo 'What server would you like to do? (Enter the number of your choice)'
 echo ''
 while true; do
      echo '1. Install LAMP server ?'
      echo '2. Install SSH server ?'
      echo '3. Install FTP server ? (It can configure two daemons: pure-ftpd and vsftpd)'
      echo '4. Install DHCP server ?'
      echo '5. Install OpenLDAP Server ?'
      echo '6. Install NFS server ?'
      echo '7. Install NIS server ?'
      echo '8. Install Kerberos server ?'
      echo '9. Install KDNS server ?'
      echo '10. Install HTTP server (Basic apache2) ?'
      echo '11. Return'
      echo ''
      read -p 'Choose Command: ' INPUT
 # This package is installed if a pattern is selected to have a working update path
 if [ "$INPUT" -eq 1 ]; then
   $ZYPPER install patterns-openSUSE-lamp_server
   echo 'Done.'
   install_various_servers
 # This package contains the YaST2 component for SSH server configuration.
 elif [ "$INPUT" -eq 2 ]; then
     $ZYPPER install yast2-sshd
     echo 'Done.'
     install_various_servers
 # This package contains the YaST2 component for FTP configuration. It can configure two daemons: pure-ftpd and vsftpd.
 elif [ "$INPUT" -eq 3 ]; then
     $ZYPPER install yast2-ftp-server
     echo 'Done.'
     install_various_servers
 # This package contains the YaST2 component for DHCP server configuration.
 elif [ "$INPUT" -eq 4 ]; then
     $ZYPPER install yast2-dhcp-server
     echo 'Done.'
     install_various_servers
 # Provides basic configuration of an OpenLDAP Server over YaST2 Control Center and during installation.
 elif [ "$INPUT" -eq 5 ]; then
     $ZYPPER install yast2-ldap-server
     echo 'Done.'
     install_various_servers
 # The YaST2 component for configuration of an NFS server. NFS stands for network file system access. It allows access to files on remote machines.
 elif [ "$INPUT" -eq 6 ]; then
     $ZYPPER install yast2-nfs-server
     echo 'Done.'
     install_various_servers
 # The YaST2 component for NIS server configuration. NIS is a service similar to yellow pages.
 elif [ "$INPUT" -eq 7 ]; then
     $ZYPPER install yast2-nis-server
     echo 'Done.'
     install_various_servers
 # Provides basic configuration of a Kerberos server over the YaST2 Control Center.
 elif [ "$INPUT" -eq 8 ]; then
     $ZYPPER install yast2-kerberos-server
     echo 'Done.'
     install_various_servers
 # This package contains the YaST2 component for DNS server configuration.
 elif [ "$INPUT" -eq 9 ]; then
     $ZYPPER install yast2-dns-server
     echo 'Done.'
     install_various_servers
 # This package contains the YaST2 component for HTTP server (Apache2) configuration.
 elif [ "$INPUT" -eq 10 ]; then
     $ZYPPER install yast2-http-server
     echo 'Done.'
     install_various_servers
 # Return
 elif [ "$INPUT" -eq 11 ]; then
     clear && main
 else
# Invalid Choice
    echo 'Invalid, choose again.'
    install_various_servers
 fi
done
}

# Install development tools (you can put here your favourites development tools applications)
install_devlopment_tools() {
 echo 'Installing development tools...'
 $ZYPPER install bluefish \
                 bzr \
                 devscripts \
                 flex \
                 gcc \
                 gcc-c++ \
                 git \
                 glade \
                 java-1_7_0-openjdk-devel \
                 python3 \
                 qt-creator \
                 ruby \
                 vim-enhanced
 echo 'Done.'
 main
}

# Install virtualization management
install_virtualization_tools() {
 INPUT=0
 echo ''
 echo 'What would you like to do? (Enter the number of your choice)'
 echo ''
 while true; do
      echo '1. Install Oracle VM VirtualBox (Not VirtualBox-OSE) ?'
      echo '2. Install Install XEN management tools (manage with yast2) ?'
      echo '3. Install Install KVM ?'
      echo '4. Return'
      echo ''
      read -p 'Choose Command: ' INPUT
 
 # Oracle VM VirtualBox
 if [ "$INPUT" -eq 1 ]; then
   echo 'Searching VirtualBox...'
   zypper --no-cd search -i VirtualBox | grep -i 'Oracle VM VirtualBox' # Check if teamviewer is install (if not, download and install)
   if [ $? -ne 0 ]; then
     move_tmp_dir
     if [ $(uname -i) = 'i386' ]; then
       wget http://download.virtualbox.org/virtualbox/4.2.12/VirtualBox-4.2-4.2.12_84980_openSUSE114-1.i586.rpm
     elif [ $(uname -i) = 'x86_64' ]; then
         wget http://download.virtualbox.org/virtualbox/4.2.12/VirtualBox-4.2-4.2.12_84980_openSUSE114-1.x86_64.rpm
     fi
       echo 'Installing Oracle VM VirtualBox...'
       $ZYPPER install kernel-devel \
                       kernel-desktop-devel \
                       gcc \
                       make \
                       VirtualBox-4.2-4.2.12_84980_openSUSE114-1.x86_64.rpm
       rm *.rpm # Clean rpm in custom tmp dir
   fi
   echo 'Done.'
   install_virtualization_tools
   
 # Meta package for pattern xen_server
 elif [ "$INPUT" -eq 2 ]; then
     $ZYPPER install patterns-openSUSE-xen_server
     echo 'Done.'
     install_virtualization_tools
 
 # kvm - Kernel-based Virtual Machine
 elif [ "$INPUT" -eq 3 ]; then
     $ZYPPER install kvm
     echo 'Done.'
     install_virtualization_tools
     
 # Return
 elif [ "$INPUT" -eq 4 ]; then
     clear && main
 
 # Invalid Choice
 else
     echo 'Invalid, choose again.'
     install_virtualization_tools
fi
done
}

# Install third party applications (Google Chrome, Google Music, Steam, TeamViewer etc ..)
install_thirdparty_applications() {
 INPUT=0
 echo ''
 echo 'What would you like to do? (Enter the number of your choice)'
 echo ''
 while true; do
      echo '1. Install Google Chrome ?'
      echo '2. Install Google Music ?'
      echo '3. Install Steam ?'
      echo '4. Install TeamViewer ?'
      echo '5. Install Skype ?'
      echo '6. Install DVD playback tools ? (libdvdcss2)'
      echo '7. Install Restricted formats (vendor change for some packages)?'
      echo '8. Return'
      echo ''
      read -p 'Choose Command: ' INPUT
 # Google Chrome
 if [ "$INPUT" -eq 1 ]; then
 zypper lr -u | grep -i "http://dl.google.com/linux/chrome/rpm/stable/x86_64" # Cheking if google-chrome is in your repositories
   if [ $? -ne 0 ]; then # if not, add it
     echo 'Add google-chrome repositories'
     zypper addrepo -f "http://dl.google.com/linux/chrome/rpm/stable/x86_64" "google-chrome"
   fi
   $ZYPPER install google-chrome-stable
   echo 'Done.'
   install_thirdparty_applications
 
 # Google musique manager
 elif [ "$INPUT" -eq 2 ]; then
     zypper lr -u | grep -i "http://dl.google.com/linux/musicmanager/rpm/stable/x86_64"
     if [ $? -ne 0 ]; then
       echo 'Add google-musicmanager-beta repositories'
       zypper addrepo -f "http://dl.google.com/linux/musicmanager/rpm/stable/x86_64" "google-musicmanager"
     fi
     $ZYPPER install google-musicmanager-beta
     echo 'Done.'
     install_thirdparty_applications
 
 # Steam
 elif [ "$INPUT" -eq 3 ]; then
     zypper lr -u | grep -i "http://download.opensuse.org/repositories/games/openSUSE_$RELEASE"
     if [ $? -ne 0 ]; then
       echo 'Add official community repositories Games'
       zypper addrepo -f "http://download.opensuse.org/repositories/games/openSUSE_$RELEASE/" "openSUSE BuildService - Games"
     fi
     $ZYPPER install steam
     echo 'Done.'
     install_thirdparty_applications
 
 # TeamViewer
 elif [ "$INPUT" -eq 4 ]; then
     $ZYPPER search -i | grep -i teamviewer # Check if teamviewer is install (if not, download and install)
     if [ $? -ne 0 ]; then
       move_tmp_dir
       echo 'Downloading TeamViewer...'
       wget http://downloadeu1.teamviewer.com/download/teamviewer_linux.rpm # Download rpm on teamviewer website (no_arch)
       echo 'Installing TeamViewer...'
       $ZYPPER install teamviewer_linux.rpm
       rm *.rpm # Clean rpm in custom tmp dir
     else
         echo 'TeamViewer is already installed'
     fi
     cd
     echo 'Done.'
     install_thirdparty_applications
 
 # Skype
 elif [ "$INPUT" -eq 5 ]; then
     $ZYPPER search -i | grep -i skype # Check if skype is install (if not, download and install)
     if [ $? -ne 0 ]; then
       move_tmp_dir
       echo 'Downloading Skype...'
       wget http://download.skype.com/linux/skype-4.2.0.11-suse.i586.rpm # Download rpm on skype website (juste 32bit rpm)
       echo 'Installing Skype.....'
       $ZYPPER install skype-4.2.0.11-suse.i586.rpm
       rm *.rpm # Clean rpm in custom tmp dir
     else
         echo 'Skype... is already installed'
     fi
     echo 'Done.'
     install_thirdparty_applications
 
 # DVD playback tools (need VLC repositories for libdvdcss2)
 elif [ "$INPUT" -eq 6 ]; then
     zypper lr -u | grep -i "http://download.videolan.org/pub/vlc/SuSE/$RELEASE"
     if [ $? -ne 0 ]; then
       echo 'Add VLC repositories'
       zypper addrepo -f "http://download.videolan.org/pub/vlc/SuSE/$RELEASE/" "VLC"
     fi
     $ZYPPER install libdvdcss2
     echo 'Done.'
     install_thirdparty_applications
 
 # Installing the packages needed to playback most multimedia formats - including MP3, DVDs etc., with Kaffeine (video) and Amarok (audio)
 elif [ "$INPUT" -eq 7 ]; then
     zypper lr -u | grep -i "http://ftp.gwdg.de/pub/linux/packman/suse/openSUSE_$RELEASE" 
     if [ $? -ne 0 ]; then
       echo 'Add Packman Repository'
       zypper addrepo -f "http://ftp.gwdg.de/pub/linux/packman/suse/openSUSE_$RELEASE/" "Packman Repository"
     fi
     echo 'PLEASE : You may be asked if you want to allow vendor change for some packages - allow it'
     $ZYPPER install ffmpeg \
                     k3b-codecs \
                     gstreamer-fluendo-mp3 \
                     gstreamer-0_10-plugins-bad \
                     gstreamer-0_10-plugins-ugly\
                     gstreamer-0_10-plugins-ugly-orig-addon \
                     gstreamer-0_10-plugins-ffmpeg \
                     lame \
                     libxine2-codecs
     echo 'Done.'
     install_thirdparty_applications
     
# Return
elif [ "$INPUT" -eq 8 ]; then
    clear && main
else
# Invalid Choice
    echo 'Invalid, choose again.'
    thirdparty
fi
done
}

# Clean the system
clean_system() {
 INPUT=0
 echo ''
 echo 'What would you like to do? (Enter the number of your choice)'
 echo ''
 while true; do
      echo ''
      echo '1. Clean Package Cache ?'
      echo '2. Clean tildes in users home ?'
      echo '3. Return?'
      echo ''
      read -p 'Choose Command: ' INPUT

 # Clean Package Cache
 if [ "$INPUT" -eq 1 ]; then
   zypper clean --all
   echo 'Done.'
   clean_system
   
 # Clean tildes in user's home. Tilde is a backup file 
 elif [ "$INPUT" -eq 2 ]; then
     echo 'Cleaning tildes ...'
     find /home -name "*~" -exec rm -i {} \; -or -name ".*~" -exec rm -i {} \;
     echo 'Done.'
     clean_system
     
 # Return to the main menu
 elif [ "$INPUT" -eq 3 ]; then
     clear && main
     
 # Invalid Choice
 else
     echo 'Invalid, choose again.'
     clean_system
 fi
done
}

# Exit with confirmation
bye_bye() {
echo ''
read -p 'Are you sure you want to quit? (Y/n) '
if [ "$REPLY" == 'n' ]; then
    clear && main
else
    exit
fi
}

# The main function
main() {
INPUT=0
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while true; do
     echo '1. Perform system update ?'
     echo '2. Apply the needed patches ?'
     echo '3. Install official community repositories ?'
     echo '4. Install unofficial community repositories ?'
     echo '5. Install your favourites applications ?'
     echo '6. Install system tools applications ?'
     echo '7. Install various servers and control them with yast2 ?'
     echo '8. Install development tools ?'
     echo '9. Install virtualization tools ?'
     echo '10. Install third party applications ? (Google Chrome, Steam etc...)'
     echo '11. Cleanup the system ?'
     echo '12. Quit?'
     echo ''
     read -p 'Choose Command: ' INPUT
# System Upgrade
if [ "$INPUT" -eq 1 ]; then
    clear && system_upgrade
# Apply the needed patches
elif [ "$INPUT" -eq 2 ]; then
    clear && system_patch
# Install official community repositories
elif [ "$INPUT" -eq 3 ]; then
    clear && install_official_com_repo
# Install unofficial community repositories
elif [ "$INPUT" -eq 4 ]; then
    clear && install_unofficial_com_repo
# Install your favourites applications
elif [ "$INPUT" -eq 5 ]; then
    clear && install_favorite_applications
# Install system tools applications
elif [ "$INPUT" -eq 6 ]; then
    clear && install_system_tools
# Install various servers and control them with yast2
elif [ "$INPUT" -eq 7 ]; then
    clear && install_various_servers 
# Install development tools
elif [ "$INPUT" -eq 8 ]; then
    clear && install_devlopment_tools
# virtualization
elif [ "$INPUT" -eq 9 ]; then
    clear && install_virtualization_tools
# Install third party applications
elif [ "$INPUT" -eq 10 ]; then
    clear && install_thirdparty_applications   
# Cleanup System
elif [ "$INPUT" -eq 11 ]; then
    clear && clean_system 
# End
elif [ "$INPUT" -eq 12 ]; then
    bye_bye
else
# Invalid Choice
    echo 'Invalid, choose again.'
    main
fi
done
}

# Run the main function
main
# End of script
