# heresy_etc

heresy_etc simplifies maintenance of your configuration files in /etc, using 
the power of git.

heresy_etc's benefits are:

* You won't be hassled about a .new file if you never modified the old file.

* And even if you have modified the old file, you won't be hassled if the
.new file is the same as last time you were hassled about it.

* If heresy_etc does need to hassle you, you can use the git mergetool of your
choice (for example, kdiff3 or meld) to merge the old and new files.

* If you mess up a file, you can restore it manually from git at any time.

* (TODO) Multiple host sync

By design, heresy_etc is almost entirely unlike etckeeper.

* heresy_etc has no user interface of its own.  It is integrated into slackpkg.
It runs only when slackpkg has installed or updated packages, and only if there
are significant changes in /etc.  This is the only time when heresy_etc reads
or writes /etc. At all other times, /etc belongs to you.

* Only git is supported.

* /etc is not a git repository -- the repository is in /var/cache/heresy/etc

* heresy_etc considers any object with unusual permissions or ownership to
potentially be security-sensitive, and absolutely refuses to track it.
