#!/bin/bash

SERVER=euler
HOST=$(hostname -s)
echo "HOST=" $HOST

# Codenames for Debian suites according to their alias.
# Update these when needed.
UNSTABLE_CODENAME="sid"
TESTING_CODENAME="jessie"
STABLE_CODENAME="wheezy"
STABLE_BACKPORTS_SUITE="$STABLE_CODENAME-backports"

# List of Ubuntu suites. Update these when needed.
UBUNTU_SUITES=( "saucy" "raring" "quantal" "precise" "oneiric" "natty" "lucid" "hardy" )

# List of Debian suites.
DEBIAN_SUITES=( $UNSTABLE_CODENAME $TESTING_CODENAME $STABLE_CODENAME "unstable" "testing" "stable" )

RELEASE="testing"

# Some utilities
contains () {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

check_repo () {
    local DIST
    
    contains $1 "${UBUNTU_SUITES[@]}"
    isUbuntu=$?

    contains $1 "${DEBIAN_SUITES[@]}"
    isDebian=$?

    if [[ "$isUbuntu" == 1 && "$isDebian" == 1 ]] ; then
	echo "$1 is unsupported"
	echo "please check your distribution is supported"
	return 1
    fi

    DIST=$1
  # Optionally change Debian release states in $DIST to their names.
    case "$1" in
	$UNSTABLE_CODENAME)
DIST="unstable"
;;
$TESTING_CODENAME)
DIST="testing"
;;
$STABLE_CODENAME)
DIST="stable"
;;
esac
RELEASE="$DIST"

if [ "$HOST" == "$SERVER" ] ; then
    pushd ~/public_html/debian > /dev/null ;
    if [ ! -d "$DIST"_pool ] ; then
	echo $DIST"_pool : no such directory - please check names of distribution"
	echo "please check your distribution is supported or that $DIST_pool has been created"
	ls | grep pool | grep -v "old"
	popd > /dev/null
	return 1
    fi
    popd > /dev/null
fi
return 0
}

update_repo () {
    check_repo $1
    isRepo=$?
    [ "$isRepo" == 1 ] &&  (echo "check_repo failed" && return 1)
    
    local DIST
    DIST=$RELEASE
    pushd ~/public_html/debian > /dev/null ;
    
    dpkg-scansources "$DIST"_pool  /dev/null > dists/$DIST/main/source/Sources || return 1;
    dpkg-scanpackages -a i386 "$DIST"_pool /dev/null > dists/$DIST/main/binary-i386/Packages || return 1;
    dpkg-scanpackages -a amd64 "$DIST"_pool /dev/null > dists/$DIST/main/binary-amd64/Packages || return 1;
    apt-ftparchive generate -c=aptftp_"$DIST".conf aptgenerate_$DIST.conf || return 1;
    apt-ftparchive release -c=aptftp_"$DIST".conf dists/$DIST > dists/$DIST/Release || return 1;
    rm -f dists/$DIST/Release.gpg
    gpg -u 074F939C --passphrase-file ~trophime/bin/.debian -bao dists/$DIST/Release.gpg dists/$DIST/Release || return 1;
    popd > /dev/null
    
    return 0
}

update_cowbuilder () {
    check_repo $1
    [ "$isRepo" == 1 ] &&  (echo "check_repo failed" && return 1)
    
    sudo DIST=$1 cowbuilder --update  --override-config --configfile ~trophime/.pbuilderrc  || return 1; 
    return 0
}

clean_cowbuilder () {
    check_repo $1
    [ "$isRepo" == 1 ] &&  (echo "check_repo failed" && return 1)
    
    sudo DIST=$1 pbuilder --clean --configfile ~trophime/.pbuilderrc  || return 1; 
    return 0
}
