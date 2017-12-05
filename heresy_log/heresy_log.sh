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
# heresy_log.sh
#
# Defines these functions
#   h_log
#
#===============================================================================

H_LOGFILE=${H_LOGFILE:-/var/log/slackpkg/slackpkg.log}
mkdir -p "$(dirname "$H_LOGFILE")"

#-------------------------------------------------------------------------------

function h_log()
{
  if [ "$1" = 'start' ]; then
    H_LOG_PKG="$3"
  elif [ "$1" = 'finish' ]; then
    case "$2" in
      installpkg|upgradepkg)
        if [ -f /var/log/packages/"$3" ]; then
          echo "$(date --rfc-3339=seconds) $2 $1 ok" >> "$H_LOGFILE"
        else
          echo "$(date --rfc-3339=seconds) $2 $1 failed" >> "$H_LOGFILE"
        fi
      removepkg)
        if [ -f /var/log/packages/"$3" ]; then
          echo "$(date --rfc-3339=seconds) $2 $1 failed" >> "$H_LOGFILE"
        else
          echo "$(date --rfc-3339=seconds) $2 $1 ok" >> "$H_LOGFILE"
        fi
      
      *)
    esac


  echo "$(date --rfc-3339=seconds) $2 $1 start" >> "$H_LOGFILE"
  return 0
}

#-------------------------------------------------------------------------------

function hl_finish()
{
  echo "$(date --rfc-3339=seconds) $2 $1 finish" >> "$H_LOGFILE"
  return 0
}

#===============================================================================
