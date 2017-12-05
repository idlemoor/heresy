## heresy_rollback

heresy_rollback lets you revert a package that was recently upgraded. When you
run 'slackpkg upgrade' (or 'slackpkg upgrade-all'), if heresy_rollback is
enabled, a copy of each package will be saved before it is upgraded. Please
note, this makes slackpkg slower and uses a lot of disk space. You can only
rollback packages that have been upgraded by slackpkg when heresy_rollback is
installed and enabled.

*IMPORTANT* Before doing a major upgrade with slackpkg (for example, from
Slackware 14.2 to -current or 15.0), you should probably disable
heresy_rollback, and then re-enable it after the major upgrade is finished.

Two commands are included: rollbackpkg and remakepkg.


### rollbackpkg

To rollback some saved packages, use the rollbackpkg command:

  rollbackpkg pkg1 pkg2...


### remakepkg

The remakepkg command reconstructs an installable Slackware package from the
installed files on your running system and the saved package metadata in
/var/log/packages. This command is used by heresy_rollback, but you can also
use it as a standalone utility.

  remakepkg [--quiet] pkg1 pkg2...

The remade packages will be put into $OUTPUT (default: /tmp), and will have an
extra string added to the package tag ($EXTRATAG, default: _remake)

If you have modified or deleted any files since the original package was
installed, the remade package will not be an exact copy of the original
package. In particular, if you have changed any configuration files in /etc,
the remade package will contain your own configuration, not the original
configuration.
