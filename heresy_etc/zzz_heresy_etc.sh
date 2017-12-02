# This file is part of heresy_etc
# http://github.com/idlemoor/heresy_etc
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
#-------------------------------------------------------------------------------
#
# zzz_heresy_etc.sh
#
# Replaces these functions in slackpkg's post-functions.sh
#   looknew
# Adds these functions
#   he_copy_to_repo
#   he_merge_all
#   he_merge
#
#-------------------------------------------------------------------------------

H_CONFDIR=${H_CONFDIR:-/etc/slackpkg}
if [ -e "$H_CONFDIR"/heresy_etc.conf ]; then
  . "$H_CONFDIR"/heresy_etc.conf
fi

H_STATEDIR=${H_STATEDIR:-/var/lib/heresy}
H_ETC_REPO="$H_STATEDIR"/etc
[ -d "$H_ETC_REPO" ] || mkdir -p "$H_ETC_REPO"

#-------------------------------------------------------------------------------

looknew()
# heresy_etc version of slackpkg's looknew.
{
	# with ONLY_NEW_DOTNEW set, slackpkg will search only for
	# .new files installed in actual slackpkg's execution
	if [ "$ONLY_NEW_DOTNEW" = "on" ]; then
		ONLY_NEW_DOTNEW="-cnewer $TMPDIR/timestamp"
	else
		ONLY_NEW_DOTNEW=""
	fi

	echo -e "\nSearching for NEW configuration files"
	FILES=$(find /etc -name "*.new" ${ONLY_NEW_DOTNEW} \
		-not -name "rc.inet1.conf.new" \
		-not -name "group.new" \
		-not -name "passwd.new" \
		-not -name "shadow.new" \
		-not -name "gshadow.new" 2>/dev/null)
	if [ "$FILES" != "" ]; then
		echo -e "\n\
Some packages had new configuration files installed.
You have five choices:

  (M)erge the new files with heresy_etc

	(K)eep the old files and consider .new files later

	(O)verwrite all old files with the new ones. The
	   old files will be stored with the suffix .orig

	(R)emove all .new files

	(P)rompt M, K, O, R selection for every single file

What do you want (M/K/O/R/P)?"
		answer	
		case $ANSWER in
			M|m)
				he_merge_all
				break
			;;
			K|k)
				break
			;;
			O|o)
				for i in $FILES; do
					overold $i
				done
				break
			;;
			R|r)
				for i in $FILES; do
					removeold $i
				done
				break
			;;
			P|p)
				echo "Select what you want file-by-file"
				for i in $FILES; do
					GOEX=0
					while [ $GOEX -eq 0 ]; do
						echo
						showmenu $i "(K)eep" "(O)verwrite" "(R)emove" "(D)iff" "(M)erge"
						read ANSWER
						case $ANSWER in
							O|o)
								overold $i
								GOEX=1
							;;
							R|r)
								removeold $i
								GOEX=1
							;;
							D|d)
								showdiff $1
							;;
							M|m)
								he_merge $1
							;;
							K|k|*)
								GOEX=1
							;;
						esac
					done
				done
				break
			;;
			*)
				echo "OK! Your choice is nothing! slackpkg will Keep the old files for you to deal with later"
			;;
		esac
	else
		echo -e "\t\tNo .new files found."
	fi
}

#-------------------------------------------------------------------------------

he_copy_to_repo()
# Copy "safe" files and links from /etc to $H_ETC_REPO and optionally commit
# $1 - optional commit message; no message => no commit
{
  find /etc/ -depth -user root -group root \
    -type d \! -perm 755 -prune \
    -o \( \( -type f \( -perm 755 -o -perm 644 \) \) -o -type l \) \
    -print0 2>/dev/null | \
    rsync -rlpgoc --delete --exclude='.*' --from0 --files-from=- / "$H_ETC_REPO"/
  if [ -n "${1:-}" ]; then
    cd "$H_ETC_REPO"
    if [ -n "$(git status -s .)" ]; then
      git add .
      git commit -m "$1"
    fi
    cd - >/dev/null
  fi
  return 0
}

#-------------------------------------------------------------------------------

he_merge_all()
{
  hostbranch="$(cat /etc/HOSTNAME)"

  # If we have no repo, clone it from upstream or create it from /etc
  if [ ! -d "$H_ETC_REPO"/.git ]; then
    rm -rf "$H_ETC_REPO"
    mkdir -p "$H_ETC_REPO"
    if [ -n "$H_ETC_UPSTREAM" ]; then
      git clone "$H_ETC_UPSTREAM" "$H_ETC_REPO"
    else
      git init "$H_ETC_REPO"
      cd "$H_ETC_REPO"
      echo "*.new" > .gitignore
      he_copy_to_repo "Initialise repository on $hostbranch"
    fi
  fi

  # If we have no hostbranch, create it, else sync the repo and commit
  cd "$H_ETC_REPO"
  if [ "$(git branch --list "$hostbranch")" = '' ]; then
    if [ "$(git branch --list origin/"$hostbranch")" = '' ]; then
      git checkout -b "$hostbranch" master
    else
      git checkout "$hostbranch" -t origin/"$hostbranch"
    fi
  else
    git checkout "$hostbranch"
    he_copy_to_repo 'Commit manual changes since last merge'
  fi

  ####
  # if master has an upstream, pull it.
  # if [ "$H_ETC_PULL" = "yes" ] || [ "$H_ETC_PULL" = "force" ]; then
  #   git fetch --all
  #   git checkout master
  #   if [ "$H_ETC_PULL" = 'force' ]; then
  #     git merge origin/master
  #   else
  #     git merge origin/master
  #   fi
  # fi
  ####

  # Capture all .new files into master. They're listed in .gitignore,
  # so git will only see them when we rename them, and only if they're
  # different to what's already in the branch :-)
  git checkout master
  newfiles=$(find . -name '*.new')
  for configfile in $newfiles ; do
    mv "$configfile" "$(echo "$configfile" | sed 's/\.new$//')"
  done
  if [ -n "$(git status -s .)" ]; then
    git add .
    git commit -m 'Merge .new files into master'
  fi

  # Merge master into the host branch.
  git checkout "$hostbranch"
  git rebase master
  if [ -n "$(git ls-files --abbrev --unmerged)" ]; then
    git mergetool
    #### give the user a chance to bail out here and leave /etc unchanged
    git commit -m "Merge .new files into $hostbranch"
  fi

  # Copy back to /etc.
  rsync -rlpgoc --exclude='.*' "$H_ETC_REPO"/ /etc/
  for configfile in $newfiles ; do
    rm /etc/$configfile
  done

  # Push back to the remote repo
  #### to be implemented

  return 0
}
