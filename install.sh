#!/bin/sh

#
# If compiling at the BIC in /data/aces/aces1/, do "newgrp aces"
# before this script so that files are accounted for in the aces
# group quota.
#
umask 077
INSTALL_DIR=$PWD/`uname`-`uname -m`
INSTALL_RELATIVE_DIR=`uname`-`uname -m`
mkdir -p ${PWD}/bin

ANIMAL=no
MRISIM=no
MAGICK=no
GIT=yes
CVS=no

# Note: Variable LD_LIBRARY_PATH needs to exists in order to change
#       it inside the Makefile. Strange...
export LD_LIBRARY_PATH=
export DYLD_LIBRARY_PATH=

if [[ "`uname -n`" =~ "seawolf1" ]] ; then
  echo 'Using default gcc 4.4.7 on orcinus...'
  ln -sf /usr/bin/gcc ${PWD}/bin/gcc
  ln -sf /usr/bin/g++ ${PWD}/bin/g++
  ln -sf /usr/bin/cpp ${PWD}/bin/cpp
  export PATH=${PWD}/bin:${PATH}
fi
if [[ "`uname -n`" =~ "ace-ws-29" ]] ; then
  echo 'Using default gcc 4.4.7 on spirit...'
#   ln -sf /usr/bin/gcc-4.2 ${PWD}/bin/gcc
#   ln -sf /usr/bin/g++-4.2 ${PWD}/bin/g++
#   ln -sf /usr/bin/cpp-4.2 ${PWD}/bin/cpp
#   export PATH=${PWD}/bin:${PATH}
fi
if [[ "`uname -n`" =~ "ace-ws-88" ]] ; then
  echo 'Using default gcc 4.7 on ace-ws-88...'
  ln -sf /usr/bin/gcc-4.7 ${PWD}/bin/gcc
  ln -sf /usr/bin/g++-4.7 ${PWD}/bin/g++
  ln -sf /usr/bin/cpp-4.7 ${PWD}/bin/cpp
  export PATH=${PWD}/bin:${PATH}
fi
if [[ "`uname -n`" =~ "zealous" ]] ; then
  export QTINC=/usr/lib64/qt4/include
  export QTDIR=/usr/lib64/qt4
  export QTLIB=/usr/lib64/qt4/lib64
  export PATH=${QTDIR}/bin:${PATH}
  echo 'Using default compiler on zealous'
fi
if [[ "`uname -n`" =~ "ip03" ]] ; then
  export TMPDIR=/tmp
  echo 'Using default compiler on RQCHP ms'
fi
if [[ "`uname -n`" =~ "lg-1r" ]] ; then
  echo 'Using default compiler on CLUMEQ guillimin'
  module load gcc/4.8.2
fi
if [[ "`uname -n`" =~ "colosse" ]] ; then
  # echo 'Using gcc 4.6 compiler on CLUMEQ colosse'
  module unload compilers/intel compilers/gcc/4.6 compilers/gcc/4.8 compilers/gcc/4.9
  module load compilers/gcc/4.8
fi
if [[ "`uname -n`" =~ "gpc" ]] ; then
  echo 'Using default compiler on GPC'
  module load gcc
fi
if [[ "`uname -n`" =~ "judge" ]] ; then
  echo 'Using gcc 4.2 on judge...'
  module add g++/4.2.4-64bit
fi

gcc --version
g++ --version
cpp --version

# you can pass flags to make using the variable MAKE_FLAGS
# example: MAKE_FLAGS="-j 8" ./install.sh

make $MAKE_FLAGS PREFIX_PATH=$INSTALL_DIR USE_GIT=$GIT USE_CVS=$CVS netpbm
make $MAKE_FLAGS PREFIX_PATH=$INSTALL_DIR ANIMAL=$ANIMAL MRI_SIM=$MRISIM USE_GIT=$GIT USE_CVS=$CVS main
make $MAKE_FLAGS PREFIX_PATH=$INSTALL_DIR ANIMAL=$ANIMAL MRI_SIM=$MRISIM USE_GIT=$GIT USE_CVS=$CVS civet inits

# Uncomment if you want to generate TGZ packages for all source codes
# make PREFIX_PATH=$INSTALL_DIR ANIMAL=$ANIMAL MRI_SIM=$MRISIM source_packages

# Save Makefile and other files to rebuild later (not readable by others).

echo "Saving compiling scripts..."
mkdir -p $INSTALL_DIR/building/
cp -p $PWD/mk_environment.pl $INSTALL_DIR/building/
cp -p $PWD/Makefile $INSTALL_DIR/building/
cp -p $PWD/install.sh $INSTALL_DIR/building/

# Create job script to run regression test.

echo "#!/bin/sh -f" > job_test
echo "source $INSTALL_RELATIVE_DIR/init.sh" >> job_test

# -animal -lobe-atlas icbm152nl-2009a
ANIMAL_Opt=""
if [ "$ANIMAL" == "yes" ] ; then
    ANIMAL_Opt="-animal -lobe_atlas icbm152nl-2009a"
fi

echo "$INSTALL_RELATIVE_DIR/CIVET-2.1.1/CIVET_Processing_Pipeline -prefix mni_icbm -sourcedir Test/ -targetdir Test/ -N3-distance 200 -lsq12 -resample-surfaces -thickness tlaplace:tfs:tlink 30:20 -VBM $ANIMAL_Opt -combine-surface -spawn -run 00100" >> job_test
chmod u+x job_test

echo "Submit file job_test to run the test case"

# Set file permissions to all.

echo "Setting file permissions..."
chmod g+rX `uname`-`uname -m`
chmod o-rwx `uname`-`uname -m`
chmod -R g+rX $INSTALL_DIR
chmod og-rwx $INSTALL_DIR/building/

