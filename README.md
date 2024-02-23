# dokuwiki-update-openbsd

This script updates a [DokuWiki](https://dokuwiki.org) instance to the latest stable version on [OpenBSD](https://openbsd.org).

Tested on [OpenBSD 7.3](https://openbsd.org/73.html) and [OpenBSD 7.4](https://openbsd.org/74.html) with [DokuWiki](https://dokuwiki.org) version 2023-04-04 "Jack Jackrum" and later, including 2024-02-06a "Kaos".

It can be configured to update [DokuWiki](https://dokuwiki.org) instances in non default locations, i.e. locations different than `/var/www/dokuwiki`.

**IMPORTANT:** Please modify the marked values (`DEST_DIR`, `WEB_USER`, `WEB_GROUP`, `DEFAULT_OWNER`) in your copy of the script to conform to your setup before executing it! If your [DokuWiki](https://dokuwiki.org) instance lives in `/var/www` then you probably only need to change `DEST_DIR`.

**Note:** It is a good idea to invalidate the [DokuWiki](https://dokuwiki.org) caches after an update. Just open and save the configuration settings in [DokuWiki](https://dokuwiki.org) once to get this done.

See [Updating DokuWiki on OpenBSD](https://www.fiwswe.de/doku.php?id=blog:updating_dokuwiki_on_openbsd) for more information and reasons for using this script instead of other methods of updating [DokuWiki](https://dokuwiki.org).
See also [Upgrading DokuWiki](https://www.dokuwiki.org/install:upgrade) for general upgrading instructions.

---
With some adjustments a similar script may also work on other UN*X operating systems.
