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
# heresy_etc.sh
#
# Adds these functions
#   he_init
#   he_to_repo
#   he_update_hostbranch
#   he_update_master
#   he_merge
#
#===============================================================================

H_STATEDIR="${H_STATEDIR:-/var/lib/slackpkg/heresy}"
H_ETC_REPO="${H_STATEDIR}/etc-repo"
H_EXCLUDES="${H_EXCLUDES:-${H_CONFDIR}/heresy-excludes.conf}"

#-------------------------------------------------------------------------------

function he_init()
{
  if [ ! -d "${H_ETC_REPO}/.git" ]; then
    mkdir -p "${H_ETC_REPO}"
    cd "${H_ETC_REPO}"
    SLKVER=$(sed -e 's/.* //' < /etc/slackware-version)
    MARCH=$(uname -m)
    case "$MARCH" in
      i386|i486|i586|i686)
        case "$SLKVER" in
          12*|13*|14.0|14.1)
            SLKARCH="i486" ;;
          *)
            SLKARCH="i586" ;;
        esac
        ;;
      *)
        SLKARCH="$MARCH"
        ;;
    esac
    mastertar="/usr/share/slackpkg/heresy/etc-master-$SLKVER-$SLKARCH.tar.gz"
    if [ -f "${mastertar}" ]; then
      tar xf "${mastertar}"
      git init
      git add . >/dev/null
      git commit -m 'Initialise master'
    else
      # improvise :(
      he_to_repo
      newfiles=$(find . -name '*.new')
      for configfile in ${newfiles} ; do
        mv "${configfile}" "${configfile%.new}"
      done
      git init
      git add . >/dev/null
      git commit -m 'Initialise master from /etc'
    fi
    git checkout -b $(hostname) master
  fi
  return 0
}

#-------------------------------------------------------------------------------

function he_to_repo()
{
  nameargs="${1:-}"
  excludeargs="--exclude='.git/'"
  if [ -n "${H_EXCLUDES}" ] && [ -f "${H_EXCLUDES}" ]; then
    excludeargs="${excludeargs} --exclude-from=\"${H_EXCLUDES}\""
  fi
  find /etc/ \
    -depth \
    -user root -group root \
    -type d \! -perm 755 -prune \
    -o \
    \( \( -type f \( -perm 755 -o -perm 644 \) \) -o -type l \) \
    ${nameargs} \
    -print 2>/dev/null \
  | \
  rsync -rlpgocv --delete \
    ${excludeargs} \
    --files-from=- \
    / "${H_ETC_REPO}"/
  return 0
}

#-------------------------------------------------------------------------------

function he_update_hostbranch()
{
  cd "${H_ETC_REPO}"
  git checkout $(hostname)
  he_to_repo "! -name '*.new'"
  if [ -n "$(git status -s .)" ]; then
    git add .
    git commit -m 'Updated from /etc'
  fi
  return 0
}

#-------------------------------------------------------------------------------

function he_update_master()
{
  cd "${H_ETC_REPO}"
  git checkout master
  he_to_repo "-name '*.new'"
  newfiles=$(find . -name '*.new')
  for configfile in ${newfiles} ; do
    mv "${configfile}" "${configfile%.new}"
  done
  if [ -n "$(git status -s .)" ]; then
    git add .
    git commit -m 'Updated master from /etc/'
  fi
  return 0
}

#-------------------------------------------------------------------------------

function he_merge()
{
  cd "${H_ETC_REPO}"
  git checkout $(hostname)
  git rebase master
  find /etc -name '*.new' -delete
  unmerged=$(git ls-files --abbrev --unmerged etc/)
  if [ "${BATCH}" = 'off' ] && [ -n "${unmerged}" ]; then
    git mergetool
    unmerged=$(git ls-files --abbrev --unmerged etc/)
    if [ -z "${unmerged}" ]; then
      git add .
      git commit -m "Rebase ${hostbranch} for merged .new files"
    fi
  fi
  if [ -n "${unmerged}" ]; then
    for renew in ${unmerged}; do
      git checkout -f "${renew}"
    done
    git add .
    git commit -m "Partial rebase ${hostbranch} for merged .new files"
    git checkout master
    for renew in ${unmerged}; do
      cp -a "${renew}" "/etc/${renew}.new"
    done
    git checkout $(hostname)
  fi
  rsync -rlpgocv \
    --exclude='.git' \
    "${H_ETC_REPO}/etc/" /etc/
  return 0
}

#===============================================================================
