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
# Overrides these variables in /etc/slackpkg.conf
#   DELALL=on --> DELALL=off
#
#===============================================================================

if [ "${DELALL}" = 'on' ]; then
  echo "heresy_rollback: Forcing DELALL=on to DELALL=off"
  echo "heresy_rollback: You can edit /etc/slackpkg.conf to make this message go away."
  echo ""
  DELALL='off'
fi

declare -A HR_SAVEPKGDIR HR_SAVEPKGNAM

#-------------------------------------------------------------------------------

function hr_save()
{
  longpkgnam="${1/%.t[blxg]z/}"
  PKGNAME=( $(grep -m 1 -- "[[:space:]]${longpkgnam}[[:space:]]" ${TMPDIR}/pkglist) )
	NAMEPKG=${PKGNAME[5]}.${PKGNAME[7]}
	FULLPATH=${PKGNAME[6]}
	CACHEPATH=${TEMP}/${FULLPATH}
	[ -d "${CACHEPATH}" ] || mkdir -p "${CACHEPATH}"

  shortpkgnam=$(cutpkg "$longpkgnam")
  oldlongpkgnam=$(ls /var/log/packages | grep -m1 -e "^${shortpkgnam}-[^-]\+-[^-]\+-[^-]\+$")
  HR_SAVEPKGDIR[${shortpkgnam}]="${CACHEPATH}"
  HR_SAVEPKGNAM[${shortpkgnam}]="${oldlongpkgnam}"
  if [ -n "${oldlongpkgnam}" ]; then
    oldpkg=$(find "${CACHEPATH}" -name "${oldlongpkgnam}.t?z" 2>/dev/null)
    if [ -z "$oldpkg" ]; then
      echo -e "\tSaving ${oldlongpkgnam}_rollback.txz..."
      OUTPUT="${CACHEPATH}" \
      EXTRATAG='_rollback' \
      remakepkg --quiet "${shortpkgnam}"
      HR_SAVEPKGNAM[${shortpkgnam}]="${oldlongpkgnam}_rollback"
    fi
  fi
  return 0
}

function hr_purge()
{
  longpkgnam="${1/%.t[blxg]z/}"
  shortpkgnam=$(cutpkg "${longpkgnam}")
  find "${HR_SAVEPKGDIR[${shortpkgnam}]}" -type f -name "${shortpkgnam}*" | \
    grep -e "^${shortpkgnam}-[^-]\+-[^-]\+-[^-]\+$" | \
    while read savefilename; do
      n="${savefilename/%.t[blxg]z/}"
      if [ "$n" != "${longpkgnam}" ] && [ "$n" != "${HR_SAVEPKGNAM[${shortpkgnam}]}" ]; then
        rm -f "${savefilename}" "${savefilename}.asc"
      fi
    done
  return 0
}

#===============================================================================
