#!/bin/bash
#
#    floreantpos_updater.sh - keeps your floreant_pos fresh
#    Copyright (C) 2015 fattire <f4ttire@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


NEEDED_PACKAGES=("git" "git-svn" "maven2" "openjdk-7-jdk" "openjdk-7-doc" "openjdk-7-jre-lib")
# source goes here
SOURCE_DIR=$HOME/floreantpos_source
# the built zips will go here
TARGET_DIR=$HOME/Desktop/floreantpos_builds
# a "live" version, suitable for running, goes here
ACTIVE_DIR=$HOME/Desktop/active_floreantpos
CUSTOM_LOGO=$ACTIVE_DIR/config/custom-logo.png

FLOREANT_SVN_URL=svn://svn.code.sf.net/p/floreantpos/code/trunk

#------------------------------------------------------------------------------------------

function about_this() {
clear
ABOUT=$( cat <<-EOF

+----------------------------------------------+
| floreant_pos_updater v.01a by fattire        |
| (@fat__tire on twitter, @fat-tire on github) |
+---------------------------------------------+-------------------------------------------+
| This program is an installer/updater.  On a Ubuntu (debian-based) system, it should     |
| download and build the very latest floreantpos .zip from the latest source.             |
|                                                                                         |
| Note that this script only creates a "fresh" .zip of FloreantPOS.  Once unzipped, it's  |
| up to you to follow the FloreantPOS instructions for setting it up, configuring it, and |
| running it.  More information is at the FloreantPOS site:                               |
|                                                                                         |
| http://wiki.floreantpos.org/installation-guide                                          |
|                                                                                         |
| Any missing system packages you will need are automatically installed, which is why you |
| need to run this run as root.  This script is written and released as open source, so   |
| please read the code to ensure you are comfortable running it with elevated privileges. |
+-----------------------------------------------------------------------------------------+

Remote FloreantPOV source repository  : $FLOREANT_SVN_URL
Local FloreantPOV source copy         : $SOURCE_DIR
Built FloreantPOS .zip will be put at : $TARGET_DIR

Checking if required build-packages are installed...
EOF
)
log "$ABOUT"
}


function check_package() {
PKG_OK=$(apt-cache policy $1 | grep "Installed")
log "Checking for $1: $PKG_OK"
if [[ "$PKG_OK" == *"(none)"* ]]; then
  log "$1 is not installed.  Installing $1..."
  sudo apt-get --force-yes --yes install $1
fi
}

function check_packages() {
log "Checking for needed packages...."
for i in "${NEEDED_PACKAGES[@]}"
do
        check_package $i
done
}

function log() {
echo "$(tput setaf 5)FLOREANTPOS-UPDATER:$(tput sgr0) $(tput setaf 7)$1$(tput sgr0)"
}

function mvn() {
  shift
  (cd $SOURCE_DIR; mvn "$0")
}

# ---- main flow begins below -------------------------------------------------------

about_this

if [ ! -n "$(command -v apt-get)" ]; then
   log "Sorry, this has to be run on a system which uses the apt package manager."
   exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "\n*** To install required system packages, this must be run as root. ***\n\nTo run this as root, type:\nsudo $0\n" 1>&2
   exit 1
fi

check_packages

log "Making $SOURCE_DIR if it doesn't exist yet..."
sudo -u "$SUDO_USER" mkdir -p "$SOURCE_DIR"
if [ ! -d "$SOURCE_DIR"/trunk/.git ]; then
   log "No source detected.  Cloning source code to directory..."
   sudo -u "$SUDO_USER" git svn clone "$FLOREANT_SVN_URL" "$SOURCE_DIR" -q
else
   log "Existing source code found."
fi
log "Updating to latest source code at $SOURCE_DIR/trunk..."
sudo -u "$SUDO_USER" git --git-dir="$SOURCE_DIR"/.git svn fetch -q
log "Done!"
log "Switching source directory to the latest code..."
sudo -u "$SUDO_USER" git --git-dir="$SOURCE_DIR"/.git checkout -q remotes/git-svn
log "Clean install maven..."
sudo -u "$SUDO_USER" mvn clean install -Dmaven.buildNumber.skip -f"$SOURCE_DIR"/pom.xml -q
log "Manually downloading a missing maven2 file..."
sudo -u "$SUDO_USER" mkdir -p $HOME/.m2/repository/org/sonatype/oss/oss-parent/4/
sudo -u "$SUDO_USER" wget -O $HOME/.m2/repository/org/sonatype/oss/oss-parent/4/oss-parent-4.pom https://repo1.maven.org/maven2/org/sonatype/oss/oss-parent/4/oss-parent-4.pom
log "Building zip for you."
sudo -u "$SUDO_USER" mvn package -Dmaven.buildNumber.skip -f"$SOURCE_DIR"/pom.xml -q
log "Build finished.  Attempting to copy .zip to $TARGET_DIR"
sudo -u "$SUDO_USER" mkdir -p "$TARGET_DIR"
sudo -u "$SUDO_USER" cp $SOURCE_DIR/target/floreantpos-*.zip $TARGET_DIR/floreantpos-build-`date +"%m-%d-%Y-%T"`.zip
log
log "If there weren't any errors, the latest build should be at:"
log
log      $(tput setaf 1)$TARGET_DIR/floreantpos-build-`date +"%m-%d-%Y-%T"`.zip
log
log "The latest source is in a git repository at:"
log
log      $(tput setaf 1)$SOURCE_DIR
log
log "Last five changes to the source:"
log
sudo -u "$SUDO_USER" git --git-dir="$SOURCE_DIR"/.git log --pretty=format:'%Cblue%h%Creset %Cgreen(%cr)%Creset -%C(yellow)%d%Creset %s' -5
log
log "This latest version, freshly baked from the oven, may have the new bug-fixes, but it may also"
log "have newly introduced bugs."
log
log "When you want a new build with the very latest source, simply run this script again."
log
log "Enjoy!"
log
log "Copying to $(tput setaf 1)$ACTIVE_DIR$(tput sgr0)"
sudo -u "$SUDO_USER" cp -r $SOURCE_DIR/target/floreantpos-bin/floreantpos/* $ACTIVE_DIR/
if [ -f $CUSTOM_LOGO ];
   then
      log "Copying $(tput setaf 1)$CUSTOM_LOGO$(tput sgr0) to $(tput setaf 1)$ACTIVE_DIR/config/logo.png$(tput sgr0)"
      sudo -u "$SUDO_USER" cp $CUSTOM_LOGO $ACTIVE_DIR/config/logo.png
fi
log "The active floreantpos directory was updated.  You can run floreant out of there."


