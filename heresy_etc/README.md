## heresy_etc

*not yet implemented*

heresy_etc simplifies maintenance of your configuration files in /etc, using 
the power of git.

heresy_etc's benefits are:

* It has no user interface of its own.  It runs only when slackpkg has
installed or updated packages.  At all other times, /etc belongs to you.

* You won't be hassled about a .new file if you never modified the old file.

* And even if you have modified the old file, you won't be hassled if the
.new file is the same as last time you were hassled about it.

* If heresy_etc does need to hassle you, you can use the git mergetool of your
choice (for example, kdiff3 or meld) to merge the old and new files.

* If you mess up a file, you can restore it manually from git.

* (TODO) Sync multiple hosts with a remote repository.

By design, heresy_etc is almost entirely unlike etckeeper:

* only git is supported
* the repository is in /var/cache/slackpkg/heresy/etc, /etc is not a git repo
* heresy_etc considers any object with unusual permissions or ownership to
potentially be security-sensitive, and absolutely refuses to track it
