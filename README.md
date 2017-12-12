# This software is INCOMPLETE and HIGHLY EXPERIMENTAL and NOT YET READY
and POTENTIALLY TOXIC

# Heresy Plugins for slackpkg

The Heresy Plugins for slackpkg simplify maintenance of your Slackware
system. Some people will think that these plugins are against the
philosophy of Slackware, hence the name 'heresy'.

* heresy_etc -- maintain your config files
* heresy_installdeps -- automatically install dependencies
* heresy_log -- keep a log of slackpkg actions
* heresy_rollback -- revert a package update
* heresy_unattended -- automatically apply updates


## heresy_etc

heresy_etc simplifies maintenance of your configuration files in /etc,
using the power of git.

* It uses 'git rebase' to merge changes from .new files into your
existing config files.

* You won't be hassled about a .new file if you never modified the old
file.

* Even if you have modified the old file, you won't be hassled if the
.new file is the same as last time you were hassled about it, or if git
can work out how to merge the changes automatically.

* If heresy_etc does need to hassle you, you can use the git mergetool
of your choice (for example, kdiff3 or meld) to merge the old and new
files.

* If you mess up a file, you can restore it manually from git.

* (TODO) Manage multiple hosts using a remote repository.

heresy_etc has no user interface of its own.  It runs only when
slackpkg has installed or updated packages.  At all other times, /etc
belongs to you.

By design, heresy_etc is almost entirely unlike etckeeper:

* heresy_etc considers any object with unusual permissions or ownership
to potentially be security-sensitive, and absolutely refuses to track it
* the repository is in /var/cache/slackpkg/heresy/etc (/etc itself is
not a git repo)
* only git is supported


## heresy_installdeps

*not yet implemented*

When you use slackpkgplus to install or upgrade packages from a
third-party repository that contains '.dep' files, heresy_installdeps
automatically adds dependencies to the package list. You can then
review the list as usual.

heresy_installdeps does *not* support package removal.


## heresy_log

heresy_log creates a log at /var/log/slackpkg.log containing details of
packages that have been installed, upgraded and removed using slackpkg.

Packages that were installed, upgraded and removed using anything else
are not logged.


## heresy_rollback

heresy_rollback lets you revert a package that was recently upgraded.
When you run 'slackpkg upgrade' (or 'slackpkg upgrade-all'), if
heresy_rollback is enabled, a copy of each package will be saved before
it is upgraded. Please note, this makes slackpkg slower and uses a lot
of disk space. You can only rollback packages that have been upgraded
by slackpkg when heresy_rollback is installed and enabled.

*IMPORTANT* Before doing a major upgrade with slackpkg (for example,
from Slackware 14.2 to -current or 15.0), you should probably disable
heresy_rollback, and then re-enable it after the major upgrade is
finished.

Two commands are included: rollbackpkg and remakepkg.


## heresy_unattended

heresy_unattended is a script which uses the other heresy plugins to
automatically keep your system up-to-date. It is intended to be called
as a cron job.
