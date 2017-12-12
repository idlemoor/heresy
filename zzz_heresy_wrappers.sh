# This file is part of the Heresy Plugins
# http://github.com/idlemoor/heresy
#
# Copyright 2017 David Spencer, Baildon, West Yorkshire, U.K.
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#===============================================================================
#
# zzz_heresy_wrappers.sh
#
# Reads config file
# Wraps these slackpkg (or slackpkgplus) functions
#   looknew
#   getpkg
#   remove_pkg
# Adds these functions
#   heresy_pkg_start
#   heresy_pkg_finish
#
#===============================================================================

H_CONFDIR=${H_CONFDIR:-/etc/slackpkg}
if [ -e "$H_CONFDIR"/heresy.conf ]; then
  . "$H_CONFDIR"/heresy.conf
fi

#===============================================================================

if [ "$H_ETC_ENABLED" = 'yes' ]; then
  eval "s_$(declare -f looknew)"
  function looknew()
  {
    set -x ####
    he_init
    he_update_hostbranch
    he_update_master
    he_merge
    s_looknew "$@"
    set +x ####
    return 0
  }
fi

#===============================================================================

if [ "$H_LOG_ENABLED" = 'yes' ] || [ "$H_ROLLBACK_ENABLED" = 'yes' ]; then

  eval "s_$(declare -f getpkg)"
  function getpkg()
  {
    heresy_pkg_start "$2" "$1"
    s_getpkg "$@"
    heresy_pkg_finish "$2" "$1"
    return 0
  }

  eval "s_$(declare -f remove_pkg)"
  function remove_pkg()
  {
    heresy_pkg_start removepkg "$1"
    s_remove_pkg "$@"
    heresy_pkg_finish removepkg "$1"
    return 0
  }

  function heresy_pkg_start()
  {
    [ "$H_LOG_ENABLED" = 'yes' ] && hl_start "$1" "$2"
    if [ "$1" = 'upgradepkg' ] || [ "$1" = 'removepkg' ]; then
      [ "$H_ROLLBACK_ENABLED" = 'yes' ] && hr_save "$2"
    fi
    return 0
  }

  function heresy_pkg_finish()
  {
    if [ "$1" = 'upgradepkg' ]; then
      [ "$H_ROLLBACK_ENABLED" = 'yes' ] && hr_purge "$2"
    fi
    [ "$H_LOG_ENABLED" = 'yes' ] && hl_finish "$1" "$2"
    return 0
  }

fi

#===============================================================================
