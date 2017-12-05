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
H_ETC_REPO="${H_STATEDIR}/etc"
H_EXCLUDES="${H_EXCLUDES:-${H_CONFDIR}/heresy-excludes.conf}"

#-------------------------------------------------------------------------------

function he_init()
{
  if [ ! -d "$H_ETC_REPO" ]; then
    mkdir -p "$H_ETC_REPO"
    tar xf /usr/share/slackpkg/heresy/etc-master-$SLKARCH.tar.gz -C "$H_ETC_REPO"
    (cd "$H_ETC_REPO"; git checkout -b $(hostname) master)
  fi
  he_update_hostbranch
  return 0
}

#-------------------------------------------------------------------------------

function he_to_repo()
{
  nameargs="${1:-}"
  excludeargs="--exclude='.git/'"
  [ -f "$H_EXCLUDES" ] && excludeargs="$excludeargs --exclude-from=\"$H_EXCLUDES\""
  find /etc/ \
    $nameargs \
    -depth -user root -group root \
    -type d \! -perm 755 -prune \
    -o \
    \( \( -type f \( -perm 755 -o -perm 644 \) \) -o -type l \) \
    -print0 2>/dev/null \
  | \
  rsync -rlpgoc --delete \
    $excludeargs \
    --from0 --files-from=- \
    / "$H_ETC_REPO"/
  return 0
}

#-------------------------------------------------------------------------------

function he_update_hostbranch()
{
  cd "$H_ETC_REPO"
    git checkout $(hostname)
    he_to_repo "! -name '*.new'"
    if [ -n "$(git status -s .)" ]; then
      git add .
      git commit -m 'Updated from /etc'
    fi
  cd - >/dev/null
  return 0
}

#-------------------------------------------------------------------------------

function he_update_master()
{
  cd "$H_ETC_REPO"
    git checkout master
    he_to_repo "-name '*.new'"
    newfiles=$(find . -name '*.new')
    for configfile in $newfiles ; do
      mv "$configfile" "${configfile%.new}"
    done
    if [ -n "$(git status -s .)" ]; then
      git add .
      git commit -m 'Updated master from /etc/'
    fi
  cd - >/dev/null
}

#-------------------------------------------------------------------------------

function he_merge()
{
  cd "$H_ETC_REPO"
  git checkout $(hostname)
  git rebase master
  find /etc -name '*.new' -delete
  unmerged=$(git ls-files --abbrev --unmerged)
  if [ "$BATCH" = 'off' ] && [ -n "$unmerged" ]; then
    git mergetool
    unmerged=$(git ls-files --abbrev --unmerged)
    if [ -z "$unmerged" ]; then
      git add .
      git commit -m "Rebase $hostbranch for merged .new files"
    fi
  fi
  if [ -n "$unmerged" ]; then
    for renew in $unmerged; do
      git checkout -f "$renew"
    done
    git add .
    git commit -m "Partial rebase $hostbranch for merged .new files"
    git checkout master
    for renew in $unmerged; do
      cp -a "$renew" /etc/"$renew".new
    done
    git checkout $(hostname)
  fi
  rsync -rlpgoc \
    --exclude='.git' \
    "$H_ETC_REPO"/ /etc/
  cd - >/dev/null
  return 0
}

#===============================================================================
