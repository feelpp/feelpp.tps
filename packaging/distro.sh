#!/bin/bash


# Source function library.
if [ -f ./distro_tools.sh ] ; then
    . ./distro_tools.sh
else
    echo "No distro_tools.sh"
    exit 0
fi

# Main code
[ $# -ge 1 ] && [ $# -le 3 ] || {
    echo "Usage: $0 action dist package_dir"
    exit 0
}

[ $# -eq 1 ] && {
    export DIST="jessie"
    export SRCDIR="pwd"
}

[ $# -eq 2 ] && {
    export DIST=$2
    export SRCDIR="pwd"
}

[ $# -eq 3 ] && {
    export DIST=$2
    export SRCDIR=$3
    [ -d $3 ] || {
	echo $3 " : no such directory"
	exit
    }
}

# Determine arch
ARCH=$(echo $(dpkg --print-architecture))

case "$1" in
    check_repo)
    check_repo $DIST
    isRepo=$?
    [ "$isRepo" == 1 ] && exit
    ;;
    update_repo)
    update_repo $DIST
    isRepo=$?
    [ "$isRepo" == 1 ]  && exit
    ;;
    update_cowbuilder)
    update_cowbuilder $DIST
    isRepo=$?
    [ "$isRepo" == 1 ]  && exit
    ;;
    build)
    pushd $SRCDIR
    [ -f debian/control ] && {
	PACKAGE=echo `dpkg-parsechangelog | sed -n 's/^Source: //p'`
	VERSION=echo `dpkg-parsechangelog | sed -n 's/^Version: //p'`
	GIT=echo `dpkg-parsechangelog | sed -n 's/^Vcs-Git: //p'`
	SVN=echo `dpkg-parsechangelog | sed -n 's/^Vcs-Svn: //p'`
    } || exit

    [ -f .git ] && svn-buildpackage --svn-ignore-new --svn-builder='DIST=$DIST ARCH=$ARCH pdebuild' --svn-lintian || exit
    [ -f .svn ] && git-buildpackage --git-builder="DIST=$DIST ARCH=$ARCH pdebuild" --git-ignore-new || exit

     # push package to the repository
    push /var/cache/pbuilder/$DIST-$ARCH/result || exit
    [ -f $PACKAGE_$VERSION.changes ] && {
	dupload -t euler_$RELEASE $PACKAGE_$VERSION.changes || exit
    }
    popd
    
    update_repo $DIST
    isRepo=$?
    [ "$isRepo" == 1 ]  && exit
    update_cowbuilder $DIST
    isRepo=$?
    [ "$isRepo" == 1 ]  && exit
    ;;
    build)
    pushd $SRCDIR
    [ -f debian/control ] && {
	PACKAGE=$(echo $(dpkg-parsechangelog | sed -n 's/^Source: //p'))
	VERSION=$(echo $(dpkg-parsechangelog | sed -n 's/^Version: //p'))
	GIT=$(echo $(dpkg-parsechangelog | sed -n 's/^Vcs-Git: //p'))
	SVN=$(echo $(dpkg-parsechangelog | sed -n 's/^Vcs-Svn: //p'))
    } || exit

    [ -f .git ] && svn-buildpackage --svn-ignore-new --svn-builder='DIST=$DIST ARCH=$ARCH pdebuild' --svn-lintian || exit
    [ -f .svn ] && git-buildpackage --git-builder="DIST=$DIST ARCH=$ARCH pdebuild" --git-ignore-new || exit

     # push package to the repository
    push /var/cache/pbuilder/$DIST-$ARCH/result > /dev/null || exit
    [ -f "$PACKAGE"_"$VERSION"_$ARCH.changes ] && {
	dupload -t euler_$RELEASE "$PACKAGE"_"$VERSION"_$ARCH.changes || exit
    }
    popd > /dev/null
    
    update_repo $DIST
    isRepo=$?
    [ "$isRepo" == 1 ]  && exit
    update_cowbuilder $DIST
    isRepo=$?
    [ "$isRepo" == 1 ]  && exit
    ;;
    
    *)
    echo "Usage: $0 {check_repo|update_repo|update_cowbuilder|build|status} [dist [package_dir]]" >&2
    exit 3
    ;;
esac

