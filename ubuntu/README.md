Feel++ PPA 
==========

WE have created a team feelpp on Launchpad
https://launchpad.net/~feelpp

The packages are available here:
https://launchpad.net/~feelpp/+archive/ppa/+packages


Feelpp ppa currently depends on 
 - https://launchpad.net/~mapnik/+archive/boost-backports-1-54
 - https://launchpad.net/~kalakris/+archive/eigen
in order to build. We use to have the ubuntu toolchain also but it recently 
included gcc 4.9 which severely breaks building feel++ (it miscompiles std c++ library).
It may  be also the reason why precise build failed on i386 (we will see with the next precise build)
