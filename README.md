salome
======

Repository for Salome 

This repository contains patches needed to perform Salome 7.3.0
installation on Debian/Ubuntu systems. You need a license for MeshGems
from [Distene](http://www.meshgems.com/) to run the BLSURF, GHS3D[PRL] and HEXOTIC plugins. 

The patches enable to use pre-requisites libraries already installed on
your machine. You can also take advantages of your multiple cores to speed
up the compilation.

Note that:
* Salome 7.3.0 do not use the brand new OCE 0.15.
It uses standard OCC 6.7.0 instead. 

* Salome 7.3.0 do compile with boost1.54 but do not run with the library
Therefore the installer use boost 1.52 from Salome distribution. Patches
for boost1.54 present for KERNEL_SRC_7.3.0 and SMESH_SRC_7.3.0 should not be applied.
They are here just for the records.

* Salome 7.3.0 do not run with graphiz 2.36. No graphviz package should be
installed so that the installer use graphviz from Salome distribution
Do not apply 0001-Fix-for-graphviz-2.36-and-later.patch for YACS_SRC_7.3.0.
It is here just for the records.

* Salome 7.3.0 requires Paraview-3.98.1 and won't work with higher version

## Installation

* Download [Salome installer](http://www.salome-platform.org/downloads/current-version/DownloadDistr?platform=Ubuntu_13.04&version=7.3.0_64bit).
* Apply patches to the installer contained in Installation/patches
* Apply patches to the sources:
   * Go to the Installation/patches directory
   * For each subdir: 
       * untar the corresponding source tarballs in Product/SOURCES
       * apply patches to the source
       * recreate the source tarball
* Prepare the xml config file for your distribution
   * get the name of your 'platform" using get_os_release.py
   * copy config_Debian_jessie_64bit.xml to config_your_platform.xml
   * replace "Debian jessie 64bit" by "your platform" into the newly created xml file
   * update the number of cores np used into the newly created xml file
   * if Products/BINARIES/"your_platform" does not exist 
       * create it
       * copy Products/BINARIES/Debian_7_64bit/homard-10.7.tar.gz

### Install the pre-requisites

To speed up installation we strongly recommend to install the following pre-requisites:
```
sudo apt-get install ...
```

### Run the installer

You can now run the installer:
```
./runInstall --file=config_your_platform.xml  -d $HOME/salome_with_paraview-7.3.0 -b -a 
```
It will also create a $HOME/salome_appli_7.3.00 directory.

To get more details on the installer script run
```
runInstall --help
```

## Configuration

Copy Configuration/SalomeApp.xml to $HOME/salome_appli_7.3.00/env.d

Define the following variables: 
```
export SalomeAppConfig=$HOME/salome_appli_7.3.00
```

Now Salome should work:
```
$HOME/salome_appli_7.3.00/runAppli
```

At this point you should get some warning in the console.
To fix the library "libCALCULATOR.so cannot be found" :
   * Got to $HOME/salome_with_paraview-7.3.0/lib/salome/
   * Add libCALCULATOR.so as a link to libCALCULATOREngine.so

## Todo

* Fix for boost 1.54
* Fix for graphviz 2.36

* Add automatic detection of MeshGems version
* Add automatic detection of OCE version
   
* Use OCE 0.15 instead of OCC 6.7.0
* Use installed netgen/libnglib
* Use metis 5.1   

* Script the whole thing 

  
