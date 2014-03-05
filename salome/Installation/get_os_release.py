#!/usr/bin/python

import platform
# import all referenced packages
import os
import sys
 
# method returns number of CPUs in the system
def cpu_count():
    ''' Returns the number of CPUs in the system
    '''
    num = 1
    if sys.platform == 'win32':
        # fetch the cpu count for windows systems
        try:
            num = int(os.environ['NUMBER_OF_PROCESSORS'])
        except (ValueError, KeyError):
            pass
    elif sys.platform == 'darwin':
        # fetch teh cpu count for MacOS X systems
        try:
            num = int(os.popen('sysctl -n hw.ncpu').read())
        except ValueError:
            pass
    else:
        # an finally fetch the cpu count for Unix-like systems
        try:
            num = os.sysconf('SC_NPROCESSORS_ONLN')
        except (ValueError, OSError, AttributeError):
            pass
 
    return num
 
 
# test the method
print( cpu_count() )

plt_name = "unknown"
plt_ver  = ""
plt_arch = ""   

plt_type = platform.system()
if plt_type=='Linux':
    plt_name, plt_ver, plt_release  = platform.linux_distribution()
    # On Debian system need to get rid of some part of version
    # ex: jessie/sid
    plt_ver = plt_ver.rsplit("/")[0]
if plt_type=='Windows':
    plt_name, plt_ver, plt_release  = platform.win32_ver()
if plt_type=='Darwin':
    plt_name, plt_ver, plt_release  = platform.mac_ver()

plt_arch, plt_exec = platform.architecture()

print plt_name
print plt_ver
print plt_arch


