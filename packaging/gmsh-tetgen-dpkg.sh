#!/bin/bash -x

#
# Automatic geenration of debian package for gmsh-tetgen
# from latest svn release
#
# $1 is the basename of the version $1~svnxxx
# $2 is the name of the dist to be considered
#

# Source function library.
SERVER=euler
HOST=$(hostname -s)
echo "HOST=" $HOST

if [ "$HOST" != "$SERVER" ] ; then
   if [ -f ./remote_distro_tools.sh ] ; then
     . ./remote_distro_tools.sh
   else
     echo "No remote_distro_tools.sh"
     exit 0
   fi
else
   if [ -f ./distro_tools.sh ] ; then
     . ./distro_tools.sh
   else
     echo "No distro_tools.sh"
     exit 0
   fi
fi

[ $# -eq 2 ] || {
      echo "Usage: $0 gmsh_version dist"
      exit 0
}

export DIST=$2
check_repo $DIST

# Determine arch
ARCH=$(echo $(dpkg --print-architecture))
[ $# -eq 3 ] && ARCH=$3
export ARCH



mkdir -p tmp

#
# Retreive the orig tarball

echo "Retrieve gmsh-tetgen from svn"
(cd tmp && svn co https://geuz.org/svn/gmsh/trunk gmsh > /dev/null 2>&1) || exit


export GMSH_VERSION=$(echo $1~svn$(cd tmp/gmsh && svnversion . | sed "s/M//" | sed "s/P//" | sed "s/S//"))
#
# On ubuntu quantal svnversion add some info after version number
# the indicators (MPS) should be deleted
#
{
  pushd /var/cache/pbuilder/$DIST-$ARCH/result > /dev/null || exit
  [ -f gmsh-tetgen_"$GMSH_VERSION"-1_$ARCH.upload ] && {
     echo "gmsh-tetgen_"$GMSH_VERSION"-1_$ARCH already exits"
     popd > /dev/null 
     exit
  }
  popd > /dev/null
}

echo "Building gmsh-tetgen_$GMSH_VERSION.tar.gz" 
(cd tmp && mv gmsh gmsh-tetgen-$GMSH_VERSION)
(cd tmp && tar --exclude-vcs -czf gmsh-tetgen_$GMSH_VERSION.orig.tar.gz gmsh-tetgen-$GMSH_VERSION)
(cd tmp && rm -rf gmsh-tetgen-$GMSH_VERSION)

#
# Retreive debian directory from Debian Science repository

echo "Retrieve debian package from Debian Science svn repository" 
(cd tmp && svn co svn://anonscm.debian.org/svn/debian-science/packages/gmsh-tetgen/ > /dev/null 2>&1) || exit

#
# Move the orig tarball

(cd tmp/gmsh-tetgen && mkdir -p tarballs)
(cd tmp && mv gmsh-tetgen_$GMSH_VERSION.orig.tar.gz gmsh-tetgen/tarballs)

#
# Update debian/changelog
#
# goto to trunk/debian
# edit changelog file
# eventually change the dist version (eg replace unstable by oneiric)
# eventually change the "author" and add nmu
#
# Question: how to automatically do that?
# dpkg-parsechangelog??
# dch --newversion version --release --distribution dist --force-save-on-release [texte]
#
# NB dch lance un editeur si texte vide

echo "Updating debian/changelog" 

(cd tmp/gmsh-tetgen/trunk && \
  dch --newversion $GMSH_VERSION-1 --distribution unstable --force-save-on-release "Update to latest svn") || exit

#
# Launch svn-buildpackage with pdebuild
#
# See http://svn-bp.alioth.debian.org/
#
# NB : see the following doc to properly install pbuilder env
# Howto pbuilder for ubuntu
# https://wiki.ubuntu.com/PbuilderHowto

# to run in //
#debuild -eDEB_BUILD_OPTIONS="parallel=4" -us -uc -b
#debuild -j4 -us -uc -b
#
# pdebuild --debbuildopts "-j4"

echo "Building the package for $DIST" 
(cd tmp/gmsh-tetgen/trunk && \
  svn-buildpackage --svn-ignore-new --svn-builder='DIST=$DIST ARCH=$ARCH pdebuild --debbuildopts -j8' --svn-lintian) || exit

#
pushd tmp/gmsh-tetgen/trunk > /dev/null

PACKAGE=$(echo $(dpkg-parsechangelog | sed -n 's/^Source: //p'))
VERSION=$(echo $(dpkg-parsechangelog | sed -n 's/^Version: //p'))
echo "Uploading "$PACKAGE"_$VERSION to $DIST repository" 

{
  pushd /var/cache/pbuilder/$DIST-$ARCH/result > /dev/null || exit
  [ -f "$PACKAGE"_"$VERSION"_$ARCH.changes ] && {
     dupload -t euler_$RELEASE "$PACKAGE"_"$VERSION"_$ARCH.changes || exit
  }
  popd > /dev/null
}
popd > /dev/null

rm -rf tmp

# update repository
update_repo $DIST

# update cowbuilder
update_cowbuilder $DIST
