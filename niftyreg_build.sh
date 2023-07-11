#!/bin/bash
#
# This script builds NiftyReg executables and libraries on Linux or MacOS,
# based on the instructions at:
#     http://cmictig.cs.ucl.ac.uk/wiki/index.php/NiftyReg_install
# It obtains the source code by cloning:
#     https://github.com/KCL-BMEIS/niftyreg
#
# The following variables may need to be modified:
# CMAKE - path to cmake executable;
# WORKDIR - path to directory for software build;
# NIFTYREG - identifier of specific build of NiftyReg.
#
# Compiled executables and libraries will be in:
#     ${WORKDIR}/${NIFTYREG}
#
# A compressed tarball of ${WORKDIR}/${NIFTYREG} is created as:
#     ${WORKDIR}/${NIFTYREG}.tar.gz

# Define path to cmake executable.
if [[ "$(uname)" == "Darwin" ]]; then
    CMAKE="/Applications/CMake.app/Contents/bin/cmake"
    PLATFORM="MacOS"
else
    CMAKE="${HOME}/sw/cmake-3.8.0-Linux-x86_64/bin/cmake"
    PLATFORM="$(uname)"
fi

# Define path to directory for software build, and ensure that it exists.
WORKDIR="$(pwd)/workdir"
mkdir -p ${WORKDIR}

# Optionally specify version number, corresponding to numeric part of git tag. 
# The most recent numeric tag (v1.3.9) is from 3 July 2012,
# and there have been many commits since.
# NIFTYREG_VERSION="1.3.9"

# Define paths to directories for Niftyreg source, build, install.
# Ensure that these directories exist and are empty.
if [[ -z "${NIFTYREG_VERSION}" ]]; then
    # No version number specified - identify by build date.
    NIFTYREG="NiftyReg-$(date +%Y.%m.%d)-${PLATFORM}"
else
    # Identify by version number.
    NIFTYREG="NiftyReg-${NIFTYREG_VERSION}-${PLATFORM}"
fi
NIFTYREG_SOURCE="${WORKDIR}/niftyreg"
NIFTYREG_BUILD="${WORKDIR}/${NIFTYREG}_build"
NIFTYREG_INSTALL="${WORKDIR}/${NIFTYREG}"
rm -rf ${NIFTYREG_SOURCE}
rm -rf ${NIFTYREG_BUILD}
rm -rf ${NIFTYREG_INSTALL}
mkdir -p ${NIFTYREG_BUILD}
mkdir -p ${NIFTYREG_INSTALL}

# Clone the Niftyreg repository.
cd ${WORKDIR}
NIFTYREG_URL="https://github.com/KCL-BMEIS/niftyreg"
git clone ${NIFTYREG_URL}
# If version number specified, checkout tag.
if ! [[ -z "${NIFTYREG_VERSION}" ]]; then
    cd niftyreg
    git checkout -b v${NIFTYREG_VERSION}_build v${NIFTYREG_VERSION}
    NIFTYREG_SOURCE=${NIFTYREG_SOURCE}/nifty_reg
    cd ..
fi

# Build the software.
cd ${NIFTYREG_BUILD}
${CMAKE} -DBUILD_ALL_DEP=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=${NIFTYREG_INSTALL} -DUSE_ALL_COMPONENTS=ON ${NIFTYREG_SOURCE} &> niftyreg_cmake.log
make &> niftyreg_make.log
make install &> niftyreg_make_install.log

# Create tarball.
cd ${WORKDIR}
tar -zcvf ${NIFTYREG}.tar.gz ${NIFTYREG}
