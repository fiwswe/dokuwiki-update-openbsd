#!/bin/sh
# Copyright (c)2023-2026 by fiwswe
# All rights reserved.
# License: MIT (https://opensource.org/license/mit)
# No warranties of any kind.

# Note: This script is intended to run on OpenBSD.
#       Tested on versions 7.3 though 7.9.
#
# This script is intended to install DokuWiki or to upgrade an existing
# DokuWiki to the latest version.
# It has been used and tested on OpenBSD with DokuWiki using httpd(8)
# or Apache httpd and PHP-FPM.
# Note: OpenBSD has DokuWiki in ports. However that version is rather
# old and can be considered outdated. Updates have not been timely.
#
# Access rights for the webserver/PHP are deliberately minimal to
# improve security. Basically everything can be read by the webserver
# but only certain directories/files can be modified. (This precludes
# using the upgrade Plugin (https://dokuwiki.org/plugin:upgrade),
# which requires write access to all of DokuWiki.)
#
# PREREQUISITES
# - curl needs to be installed (from OpenBSD ports, pkg_add curl).
# - To be able to set the access rights the script needs to run as root.
# - For actually running DokuWiki more prerequisites are necessary.
#   Refer to the documentation (https://www.dokuwiki.org/requirements).
#
# OTHER PLATFORMS
# For other platforms the actual UNIX owner:group settings as well as
# paths may need adjustment. Also OpenBSD sh(1) is based on ksh(1).
# Other platforms might use different shells which could require changes
# to the syntax. The xargs(1) -J option may not exist on Linux. Use
# -I instead (I think)?
#
# Basic workflow:
# - Fetch the latest stable version of DokuWiki from the download
#   server, then unpack it.
# - Adjust the permissions.
# - Copy the files to the destination directory.
# - Delete obsolete files.
# - Delete the DokuWiki cache.
# - Remove temporary files.

TMP_DIR='/tmp/dokuwiki'
TMP_DW='dokuwiki'

# Modify the following variables to match your setup:
DEST_DIR='/var/www/my-wiki-root'
DEFAULT_OWNER='root'
DEFAULT_GROUP='bin'
WEB_OWNER='www'
WEB_GROUP='daemon'

# For added security define all external commands with their full paths:
# Note: These paths are valid for OpenBSD. Adjust for other platforms.
CMD_CHMOD='/bin/chmod'
CMD_CHOWN='/sbin/chown'
CMD_CP='/bin/cp'
CMD_CURL='/usr/local/bin/curl'
CMD_ECHO='/bin/echo'
CMD_FIND='/usr/bin/find'
CMD_GREP='/usr/bin/grep'
CMD_INSTALL='/usr/bin/install'
CMD_MKDIR='/bin/mkdir'
CMD_MV='/bin/mv'
CMD_RM='/bin/rm'
CMD_TAR='/bin/tar'
CMD_WHOAMI='/usr/bin/whoami'
CMD_XARGS='/usr/bin/xargs'


# Make sure we are running with root permissions:
ME=`whoami`
if [ ${ME} != 'root' ]; then
	$CMD_ECHO "### $0: FATAL ERROR!"
	$CMD_ECHO "### Sorry, this script must be run with root permissions!"
	$CMD_ECHO "### You are currently running as user ${ME}."
	$CMD_ECHO '###'
	$CMD_ECHO '### The reason is the requirement to be able to set ownership of'
	$CMD_ECHO "### certain files and directories to users other than ${ME}."
 
	exit 1
fi

# Make sure curl is available:
if [ ! -x $CMD_CURL ]; then
	$CMD_ECHO "### $0: FATAL ERROR!"
	$CMD_ECHO '### Sorry, this script requires curl to be be installed!'
	$CMD_ECHO '### Please install curl, e.g using `pkg_add curl` and try again.'
 
	exit 1
fi

# Make sure the destination either doesn't exist or is a directory:
if [ -e "$DEST_DIR" ]; then
	if [ ! -d "$DEST_DIR" ]; then
		$CMD_ECHO "### $0: FATAL ERROR!"
		$CMD_ECHO "### Sorry, the destination (${DEST_DIR}) exists but is not a directory! Aborting!"

		exit 1
	fi
fi

# Give feedback in case the destination directory does not exists:
if [ ! -d "$DEST_DIR" ]; then
	$CMD_ECHO "### $0: INFO:"
	$CMD_ECHO "### The destination directory (${DEST_DIR}) does not exist!"
	$CMD_ECHO '### Did you forget to adjust this script to your setup?'
	$CMD_ECHO "### This will install a new copy of DokuWiki into ${DEST_DIR}."
fi


# Setup our temporary directory:
$CMD_MKDIR "$TMP_DIR"
cd "$TMP_DIR"


# Fetch the latest stable version of DokuWiki:
$CMD_ECHO '# Fetching latest stable DokuWiki version…'
$CMD_CURL --url 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz' > "${TMP_DW}.tgz"


# Unpack and delete the archive:
$CMD_ECHO '# Unpacking DokuWiki archive…'
$CMD_TAR -zxf "${TMP_DW}.tgz"
$CMD_RM "${TMP_DW}.tgz"
# The archive contains a top-level directory named according to the current DokuWiki
# version. As we don't know this name we rename this directory to a known name:
$CMD_FIND . -type d -name 'dokuwiki-*' -print|$CMD_XARGS -J '{}' $CMD_MV '{}' "$TMP_DW"

cd "$TMP_DW"


# Setup the access rights.
# Keep in mind that we are setting the access rights on the virgin
# copy of DokuWiki which contains neither user data nor manually
# installed plugins, templates or settings.
$CMD_ECHO '# Setting DokuWiki access rights…'
# Start out with minimum rights (no rights for the web server):
# Note: This prevents the upgrade Plugin from working.
$CMD_CHOWN -R $DEFAULT_OWNER:$DEFAULT_GROUP .

# Pattern the access rights on those of the dokuwiki port:
$CMD_FIND . -type d -exec $CMD_CHOWN :$WEB_GROUP {} +
# Make these directories writable (but not their contents):
$CMD_CHOWN $WEB_OWNER \
	conf \
	lib/plugins \
	lib/tpl
$CMD_CHOWN -R $WEB_OWNER data
# All original files are read-only except for pages
$CMD_FIND data -type f -exec $CMD_CHMOD 444 {} +
$CMD_FIND data/pages -type f -exec $CMD_CHMOD 644 {} +


#
# At this point we have an empty DokuWiki with correct permissions in
# the current directory.
#

# Create the destination if it doesn't yet exist as would happen for
# first installing DokuWiki:
if [ ! -d "$DEST_DIR" ];then
	$CMD_ECHO '# Creating the destination directory…'
	$CMD_INSTALL -do $DEFAULT_OWNER -g $WEB_GROUP "$DEST_DIR"
fi


# Copy the new files to the destination:
$CMD_ECHO '# Copy new DokuWiki to the destination…'
$CMD_CP -af * "${DEST_DIR}/"


# Now switch to the destination directory for further actions:
cd "$DEST_DIR"


# Remove DokuWiki deleted files:
$CMD_ECHO '# Remove deleted files…'
$CMD_GREP -Ev '^($|#)' data/deleted.files | $CMD_XARGS -n 1 $CMD_RM -fr
# General cleanup: Remove any old editor backups:
$CMD_ECHO '# Remove other unnecessary files…'
$CMD_FIND . -type f -name '*~' -delete


# A stale cache can cause various problems. Let's remove it:
$CMD_ECHO '# Remove the DokuWiki cache…'
$CMD_RM -rf data/cache/[0-9a-f]


# Remove the temporary data:
$CMD_ECHO '# Remove temporary data…'
$CMD_RM -rf "$TMP_DIR"


# Remind the user to rebuild the search index:
$CMD_ECHO '# Please rebuild the search index as soon as possible!'

$CMD_ECHO '# Done.'


#
# EOF.
#
