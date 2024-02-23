#!/bin/sh
# Copyright (c)2023-2024 by fiwswe
# All rights reserved.
# License: MIT (https://opensource.org/license/mit)
# No warranties of any kind.
 
# Note: This script is intended to run on OpenBSD.
#       Tested on versions 7.3 and 7.4.
#
# Basic workflow:
# - Fetch the latest stable version of DokuWiki from the download
#   server, then unpack it.
# - Adjust the permissions.
# - Copy the files to the destination directory.
# - Delete obsolete files.
# - Remove temporary files.
 
TMP_DIR='/tmp/dokuwiki'
TMP_DW='dokuwiki'
 
# Modify the following variables to match your setup:
DEST_DIR='/var/www/my-wiki-root/'
WEB_USER='www'
WEB_GROUP='daemon'
 
# Make sure we are running with root permissions:
ME=`whoami`
if [ ${ME} != 'root' ]; then
	echo "### $0: FATAL ERROR!"
	echo '### Sorry, this script must be run with root permissions!'
	echo "### You are currently running as user ${ME}."
	echo '###'
	echo '### The reason is the requirement to be able to set ownership of'
	echo "### certain files and directories to users other than ${ME}."
 
	exit 1
fi
 
# Make sure curl is available:
which curl >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "### $0: FATAL ERROR!"
	echo '### Sorry, this script requires curl to be be installed!'
	echo '### Please install curl, e.g using `pkg_add curl` and try again.'
 
	exit 1
fi
 
 
# Setup our temporary directory:
mkdir "$TMP_DIR"
cd "$TMP_DIR"
 
 
# Fetch the latest stable version of DokuWiki:
echo '# Fetching latest stable DokuWiki version…'
curl --url 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz' > "${TMP_DW}.tgz"
 
 
# Unpack and delete the archive:
echo '# Unpacking DokuWiki archive…'
tar zxf "${TMP_DW}.tgz"
rm "${TMP_DW}.tgz"
# The archive contains a top-level directory named according to the current DokuWiki
# version. As we don't know this name we rename this directory to a known name:
find . -type d -name 'dokuwiki-*' -print|xargs -J '{}' mv '{}' "$TMP_DW"
 
cd "$TMP_DW"
 
 
# Setup the access rights.
# Keep in mind that we are setting the access rights on the virgin
# copy of DokuWiki which contains neither user data nor manually
# installed plugins or templates.
echo '# Setting DokuWiki access rights…'
# Start out with minimum rights (no rights for the web server):
chown -R root:bin .
 
# Pattern the access rights on those of the dokuwiki port:
find . -type d -exec chown :"$WEB_GROUP" {} +
chown "$WEB_USER":"$WEB_GROUP" \
	conf \
	data
 
chown -R "$WEB_USER" data
find data -type f -exec chmod 444 {} +
find data/pages -type f -exec chmod 644 {} +
chown "$WEB_USER" \
	lib/plugins \
	lib/tpl
 
 
# Copy the new files to the destination:
echo '# Copy new DokuWiki to the destination…'
cp -af * "$DEST_DIR"
cd "$DEST_DIR"
 
 
# Remove DokuWiki deleted files:
echo '# Remove deleted files…'
grep -Ev '^($|#)' data/deleted.files | xargs -n 1 rm -fr
# General cleanup: Remove any old editor backups:
find . -type f -name '*~' -delete
 
 
# Remove the temporary data:
echo '# Remove temporary data…'
rm -rf "$TMP_DIR"
 
 
echo '# Done.'
 
 
#
# EOF.
#
