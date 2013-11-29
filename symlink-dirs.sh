#!/bin/sh
# Create a symlink tree, with leaf directories as symlinks.
#
# Copyright (C) 1995, 2000, 2003  Free Software Foundation, Inc.
# Copyright (C) 2013 Embecosm
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA 02110-1301, USA.
#
# As a special exception to the GNU General Public License, if you
# distribute this file as part of a program that contains a
# configuration script generated by Autoconf, you may include it under
# the same distribution terms that you use for the rest of that program.
#
# Please report bugs to <gcc-bugs@gnu.org>
# and send patches to <gcc-patches@gnu.org>.

# Syntax: symlink-dirs srcdir "ignore1 ignore2 ..."
#
# where srcdir is the directory to create a symlink tree to,
# and "ignoreN" is a list of files/directories to ignore.

prog=$0
srcdir=$1
ignore="$2"

if test $# -lt 1; then
  echo "symlink-dirs error:  Usage: symlink-dirs srcdir \"ignore1 ignore2 ...\""
  exit 1
fi

ignore_additional=". .. CVS .git"

# If we were invoked with a relative path name, adjust ${prog} to work
# in subdirs.
case ${prog} in
/* | [A-Za-z]:[\\/]*) ;;
*) prog=../${prog} ;;
esac

# Set newsrcdir to something subdirectories can use.
case ${srcdir} in
/* | [A-Za-z]:[\\/]*) newsrcdir=${srcdir} ;;
*) newsrcdir=../${srcdir} ;;
esac

pwdcmd=`which pwd`
for f in `ls -a ${srcdir}`; do
  if [ -d ${srcdir}/$f ]; then
    found=
    for i in ${ignore} ${ignore_additional}; do
      if [ "$f" = "$i" ]; then
	found=yes
      fi
    done
    if [ -z "${found}" ]; then
      echo "$f		..working in"
      if [ -L $f ]; then
	first=`(cd $f;$pwdcmd)`
	rm $f; mkdir $f
	(cd $f; ${prog} ${first} "${ignore}")
      elif [ -d $f ]; then true
      elif (ls -aF|grep /|grep -v '^\.\.*/'> /dev/null); then mkdir $f
      else
	echo "$f		..linked"
	rm -f $f
	ln -s ${srcdir}/$f .
	continue;
      fi
      (cd $f; ${prog} ${newsrcdir}/$f "${ignore}")
    fi
  else
    echo "$f		..linked"
    rm -f $f
    ln -s ${srcdir}/$f .
  fi
done

exit 0