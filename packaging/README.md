## Creating a "cowbuilder" environment

To create a cowbuilder "saucy" environment for "amd64" arch :
```
sudo mkdir /var/cache/pbuilder/saucy-amd64
sudo cowbuilder --create \
 --distribution saucy \
 --basepath /var/cache/pbuilder/saucy-amd64/base.cow \
 --mirror http://fr.archive.ubuntu.com/ubuntu/ \
 --components "main restricted universe multiverse" \
 --debootstrapopts \
 --arch \
 --debootstrapopts amd64 \
 --debootstrapopts \
 --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg
``` 

## Setup pbuilder environment

you need to modify your system or local pbuilderrc configuration file: 
```
# this is your configuration file for pbuilder.
# the file in /usr/share/pbuilder/pbuilderrc is the default template.
# /etc/pbuilderrc is the one meant for overwritting defaults in
# the default template
#
# read pbuilderrc.5 document for notes on specific options.

#AUTO_DEBSIGN=yes
ALLOWUNTRUSTED=yes
PDEBUILD_PBUILDER=cowbuilder
HOOKDIR="/var/cache/pbuilder/hook.d"

# Codenames for Debian suites according to their alias. Update these when
# needed.
UNSTABLE_CODENAME="sid"
TESTING_CODENAME="jessie"
STABLE_CODENAME="wheezy"
STABLE_BACKPORTS_SUITE="$STABLE_CODENAME-backports"

# List of Debian suites.
DEBIAN_SUITES=($UNSTABLE_CODENAME $TESTING_CODENAME $STABLE_CODENAME
    "unstable" "testing" "stable")

# List of Ubuntu suites. Update these when needed.
UBUNTU_SUITES=("trusty" "saucy" "raring" "quantal" "precise" "oneiric" "natty" "lucid" "hardy")

# Mirrors to use. Update these to your preferred mirror.
#DEBIAN_MIRROR="ftp.us.debian.org"
DEBIAN_MIRROR="mirror.switch.ch/ftp/mirror"
UBUNTU_MIRROR="mirrors.kernel.org"

# Optionally use the changelog of a package to determine the suite to use if
# none set.
if [ -z "${DIST}" ] && [ -r "debian/changelog" ]; then
    DIST=$(dpkg-parsechangelog | awk '/^Distribution: / {print $2}')
    # Use the unstable suite for certain suite values.
    if $(echo "experimental UNRELEASED" | grep -q $DIST); then
        DIST="$UNSTABLE_CODENAME"
    fi
    # Use the stable suite for stable-backports.
    if $(echo "$STABLE_BACKPORTS_SUITE" | grep -q $DIST); then
        DIST="$STABLE"
    fi
fi

# Optionally set a default distribution if none is used. Note that you can set
# your own default (i.e. ${DIST:="unstable"}).
: ${DIST:="$(lsb_release --short --codename)"}

STATENAME="$DIST"

# Optionally change Debian release states in $DIST to their names.
case "$DIST" in
    unstable)
        DIST="$UNSTABLE_CODENAME"
	STATENAME="unstable"
        ;;
    testing)
        DIST="$TESTING_CODENAME"
	STATENAME="testing"
        ;;
    stable)
        DIST="$STABLE_CODENAME"
	STATENAME="stable"
        ;;
esac

# Optionally change Debian release names in $STATENAME.
case "$DIST" in
    $UNSTABLE_CODENAME)
        STATENAME="unstable"
        ;;
    $TESTING_CODENAME)
        STATENAME="testing"
        ;;
    $STABLE_CODENAME)
        STATENAME="stable"
        ;;
esac

# Optionally set the architecture to the host architecture if none set. Note
# that you can set your own default (i.e. ${ARCH:="i386"}).
: ${ARCH:="$(dpkg --print-architecture)"}

NAME="$DIST"
if [ -n "${ARCH}" ]; then
    NAME="$NAME-$ARCH"
    DEBOOTSTRAPOPTS=("--arch" "$ARCH" "${DEBOOTSTRAPOPTS[@]}")
fi
#BASETGZ="/var/cache/pbuilder/$NAME-base.tgz"
# Optionally, set BASEPATH (and not BASETGZ) if using cowbuilder
BASEPATH="/var/cache/pbuilder/$NAME/base.cow/"
DISTRIBUTION="$DIST"
BUILDRESULT="/var/cache/pbuilder/$NAME/result/"
APTCACHE="/var/cache/pbuilder/$NAME/aptcache/"
BUILDPLACE="/var/cache/pbuilder/build/"
BINDMOUNTS="/var/cache/pbuilder/$NAME/result/"

if $(echo ${DEBIAN_SUITES[@]} | grep -q $DIST); then
    # Debian configuration
    MIRRORSITE="http://$DEBIAN_MIRROR/debian/"
    COMPONENTS="main contrib non-free"
    DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}" "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg")
    OTHERMIRROR="deb http://euler.lcmi.local/~trophime/debian/ $STATENAME main"

elif $(echo ${UBUNTU_SUITES[@]} | grep -q $DIST); then
    # Ubuntu configuration
    MIRRORSITE="http://$UBUNTU_MIRROR/ubuntu/"
    COMPONENTS="main restricted universe multiverse"
    DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}" "--keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg")
    OTHERMIRROR="deb http://euler.lcmi.local/~trophime/debian/ $STATENAME main"
else
    echo "Unknown distribution: $DIST"
    exit 1
fi
```

For more details see [PbuilderHowto](https://wiki.ubuntu.com/PbuilderHowto)

## Howto

To create a package for saucy go into the source package dir, then type:
```
DIST=saucy ARCH=amd68 pdebuild
```

## Some helpfull scripts

To update your saucy amd64 pbuilder environment
```
./distro.sh update_cowbuilder saucy amd64
```

To update your local saucy repository
```
./distro.sh update_repo saucy
```

## Examples

A script to generate a package for gmsh-tegen: see gmsh-tetgen-dpkg.sh

## TODO

* From [Ref](http://askubuntu.com/questions/265703/how-to-do-a-pbuilder-dist-build-with-dependencies-in-a-ppa) :

Chroot into your pbuilder environment to add the repository keys (or alternatively create a local keyring with those two keys and add it to APTKEYSTRINGS variable or add your local /etc/apt/trusted.gpg keyring):

* The helpfull scripts provided use a local repository created with aptftp.
* To upload the created packages into the local repository we use dupload, this should be changed to dput to facilitate the maintenance of feelpp ppa.
