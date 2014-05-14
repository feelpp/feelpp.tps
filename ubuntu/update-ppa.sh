#!/bin/sh
set -x

usage()
{
  msg=$1
  if [ -n "$msg" ]; then
    echo "Error: $msg"
  fi
  cat <<EOT
$0 [options...]
Options:
-u, --upload                         upload
    --version=<Feel++ version>       feel++ version
    --dversion=<Debian version>      debian version
EOT
}

VERSION=
DEBIAN_VERSION=

while [ -n "$1" ]; do
    case $1 in
	--version=*)
	    VERSION=`echo $1 | sed "s,^--version=\(.*\),\1,"`
	    export VERSION
	    ;;
	--dversion=*)
	    DEBIAN_VERSION=`echo $1 | sed "s,^--dversion=\(.*\),\1,"`
	    export DEBIAN_VERSION
	    ;;
	--upload|-u)
	    _WANT_UPLOAD=yes
	    ;;
	*)
	    echo $1: parametre inconnu
	    _WANT_HELP=yes;
	    _HAS_ERROR=yes
	    usage
	    exit 0
	    ;;
    esac
    shift
done

if [ -x
for i in trusty; do
    cd $i/
    cp ../feelpp-$1.tar.gz feel++_$1.orig.tar.gz
    cd feelpp
    dch -D $i -v $2~${i}1 "New upstream release" --force-distribution
    debuild -S -sa
    dput ppa:feelpp/ppa feel++_$2~${i}1_source.changes
    cd ../..
done

for i in saucy precise; do
    cd $i/
    cp ../feelpp-$1.tar.gz feel++_$1.orig.tar.gz
    cd feelpp
    dch -D $i -v $2~${i}1 "New upstream release" --force-distribution
    debuild -S -sd

    cd ../..
done

for i in trusty saucy precise; do
    cd $i/
    DEBIAN_VERSION=$(dpkg-parsechangelog | grep Version | awk '{print $2}')
    dput ppa:feelpp/ppa feel++_${DEBIAN_VERSION}_source.changes;
    cd ../
done
