# FloreantPOS Updater

[FloreantPOS](http://floreant.org/) is an open source point-of-sale (POS) system used by restaurants and such.

This [BASH](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) shell script, **floreantpos_updater.sh**, is meant to faciliate creation of up-to-date builds of the floreantpos .zip so people don't have to wait for builds to be officially released.

You can run the script in [Ubuntu](https://ubuntu.com) or any [Debian](https://debian.org)-like linux distribution that uses the [apt packaging tool](https://en.wikipedia.org/wiki/Advanced_Packaging_Tool), including on a [Virtual Machine](https://www.virtualbox.org).

The script does only a few things:

* Checks to make sure you have installed all dependencies.  If you haven't, it will install whatever is missing.
* Uses [git svn](https://git-scm.com/docs/git-svn) to update the local source code repository (and convert to a git repository) in a folder in the user's home directory.
* Builds the .zip
* Places the .zip in a folder on the user's Desktop.

That's it.  Re-running the script will refresh the source and create a new build.  This script could be put in a [cron job](https://en.wikipedia.org/wiki/Cron) to create regular "nightly" builds.  It could also easily be modified to unzip the build and deploy it to a specific location.

Because it installs any missing dependency system packages, the script must be run as root.

Also note that the floreantpos source code is stored locally as a [git repository](https://en.wikipedia.org/wiki/Git_(software)), not in [subversion](https://en.wikipedia.org/wiki/Apache_Subversion
), so it can be easily pushed to any other git repository.

This script is released under the [GPLv3](https://www.gnu.org/licenses/quick-guide-gplv3.en.html).  Use it entirely at your own risk.  See accompanying LICENSE file for details.

