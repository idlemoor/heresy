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
# heresy_rollback.sh
#
# Adds these functions
#   hr_save
#   hr_purge
#
#===============================================================================

H_STATEDIR=${H_STATEDIR:-/var/lib/slackpkg/heresy}
H_ROLLBACK_REPO="$H_STATEDIR"/rollback
[ -d "$H_ROLLBACK_REPO" ] || mkdir -p "$H_ROLLBACK_REPO"

#-------------------------------------------------------------------------------

function hr_save()
{
  echo "Saving $1"
  OUTPUT="$H_ROLLBACK_REPO" \
  EXTRATAG='_rollback' \
  remakepkg --quiet "$(echo ${1%.t?z} | rev | cut -f4- -d- | rev)"
  return 0
}

function hr_purge()
{
  #### remove any previously saved version
  #### not yet implemented
  return 0
}

#===============================================================================