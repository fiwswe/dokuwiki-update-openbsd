# dokuwiki-update-openbsd

This script updates (or installs) a [DokuWiki](https://dokuwiki.org) instance to the latest stable version on [OpenBSD](https://openbsd.org).

Tested on [OpenBSD 7.3](https://openbsd.org/73.html) to [OpenBSD 7.9](https://openbsd.org/79.html) with [DokuWiki](https://dokuwiki.org) version 2023-04-04 "Jack Jackrum" and later, including 2026-07-14b "Mort".

It can be configured to update [DokuWiki](https://dokuwiki.org) instances in non default locations, i.e. locations different than `/var/www/dokuwiki`.

**IMPORTANT:** Please modify the marked values (`DEST_DIR`, `WEB_OWNER`, `WEB_GROUP`, `DEFAULT_OWNER`, `DEFAULT_GROUP`) in your copy of the script to conform to your setup before executing it! If your [DokuWiki](https://dokuwiki.org) instance lives in `/var/www` then you probably only need to change `DEST_DIR`.

## See also
* [Updating DokuWiki on OpenBSD](https://www.fiwswe.de/doku.php?id=blog:updating_dokuwiki_on_openbsd) has more information and reasons for using this script instead of other methods of updating [DokuWiki](https://dokuwiki.org).
* [Upgrading DokuWiki](https://www.dokuwiki.org/install:upgrade) has general upgrading instructions.

---
## Usage on non-OpenBSD OSes
With some adjustments a similar script may also work on other UN*X operating systems.
