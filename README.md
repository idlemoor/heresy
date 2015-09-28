# This software is HIGHLY EXPERIMENTAL and NOT YET READY and POTENTIALLY TOXIC

etcslacker is an add-on for slackpkg that simplifies maintenance of your
Slackware system's configuration files in /etc, using the power of git.

etcslacker's advantages are:

* You won't be hassled about a .new file if you never modified the old file.

* And even if you have modified the old file, you won't be hassled if the
.new file is the same as last time you were hassled about it.

* If etcslacker does need to hassle you, you can use the git mergetool of your
choice (kdiff3, meld, etc) to merge the old and new files.

* If you mess up a file, you can restore it from the git repository at any time.

* If you have lots of hosts, you can optionally configure an external git
repository as an upstream master, and etcslacker will maintain a local host
branch based on master.  Also, etcslacker can be configured to pull and push
these branches automatically.  To set this up, edit the configuration file
/etc/slackpkg/etcslacker.conf.  [STILL IN DEVELOPMENT]

### By design, etcslacker is almost entirely unlike etckeeper.

* etcslacker stores its git repository in /var/cache/etc, not in /etc.
Only git is supported.

* etcslacker has no user interface of its own.  It is integrated into slackpkg
and it runs only when slackpkg finishes installing or updating packages, if you
select 'M(erge)'.  This is the only time when etcslacker reads or writes /etc.
At all other times, /etc belongs to you.

* etcslacker considers any object with unusual permissions or ownership to
potentially be security-sensitive, and absolutely refuses to track it.
