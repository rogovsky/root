#!/usr/bin/env bash

# Script to generate the file include/compiledata.h.
# Called by main Makefile.
#
# Author: Fons Rademakers, 29/2/2000

COMPILEDATA=$1
CXX=$2
CXXOPT=$3
CXXDEBUG=$4
CXXFLAGS=$5
SOFLAGS=$6
LDFLAGS=$7
SOEXT=$8
SYSLIBS=$9
shift
LIBDIR=$9
shift
ROOTLIBS=$9
shift
RINTLIBS=$9
shift
INCDIR=$9
shift
CUSTOMSHARED=$9
shift
CUSTOMEXE=$9
shift
ARCH=$9
shift
ROOTBUILD=$9
shift
EXPLICITLINK=$9
shift

if [ "$INCDIR" = "$ROOTSYS/include" ]; then
   INCDIR=\$ROOTSYS/include
fi
if [ "$LIBDIR" = "$ROOTSYS/lib" ]; then
   LIBDIR=\$ROOTSYS/lib
fi

if [ "$EXPLICITLINK" = "yes" ]; then
   EXPLLINKLIBS="\$LinkedLibs"
else
   EXPLLINKLIBS="\$DepLibs"
fi

if [ "$ARCH" = "macosx" ] || [ "$ARCH" = "macosx64" ] || \
   [ "$ARCH" = "macosxicc" ]; then
   macosx_minor=`sw_vers | sed -n 's/ProductVersion://p' | cut -d . -f 2`
   SOEXT="so"
   if [ $macosx_minor -ge 5 ]; then
      if [ "x`echo $SOFLAGS | grep -- '-install_name'`" != "x" ]; then
         # If install_name is specified, remove it.
         SOFLAGS="$OPT -dynamiclib -single_module -Wl,-dead_strip_dylibs"
      fi
   elif [ $macosx_minor -ge 3 ]; then
      SOFLAGS="-bundle $OPT -undefined dynamic_lookup"
      EXPLLINKLIBS=""
   else
      SOFLAGS="-bundle $OPT -undefined suppress"
      EXPLLINKLIBS=""
   fi
elif [ "x`echo $SOFLAGS | grep -- '-soname,$'`" != "x" ]; then
    # If soname is specified, add the library name.
    SOFLAGS=$SOFLAGS\$LibName.$SOEXT
    # Alternatively we could remove the soname flag.
    #    SOFLAGS=`echo $SOFLAGS | sed  -e 's/-soname,/ /' -e 's/ -Wl, / /' `
fi

# Remove -Iinclude since it is 'location' dependent
CXXFLAGS=`echo $CXXFLAGS | sed 's/-Iinclude //' `

# Remove the flags turning warnings into errors or extending
# the number of warnings.
CXXFLAGS=`echo $CXXFLAGS | sed -e 's/-Werror //g' -e 's/-Werror=\S* //g' -e 's/-Wall //g' -e 's/-Wshadow //g'  `

# Determine the compiler version
BXX="`basename $CXX`"
COMPILERVERS="$BXX"
case $BXX in
g++*)
   cxxTemp=`$CXX -dumpversion`
   COMPILERVERS="gcc"
   ;;
icc)
   cxxTemp=`$CXX -dumpversion`
   ;;
clang++*)
   cxxTemp=`$CXX --version | grep version | \
           sed 's/.*\(version .*\)/\1/; s/.*based on \(LLVM .*\)svn)/\1/' | \
           cut -d ' ' -f 2`
   COMPILERVERS="clang"
   ;;
esac

cxxMajor=`echo $cxxTemp 2>&1 | cut -d'.' -f1`
cxxMinor=`echo $cxxTemp 2>&1 | cut -d'.' -f2`
cxxPatch=`echo $cxxTemp 2>&1 | cut -d'.' -f3`
if [ "$cxxMajor" != "x" ] ; then
   COMPILERVERS="$COMPILERVERS$cxxMajor"
   if [ "$cxxMinor" != "x" ] ; then
      COMPILERVERS="$COMPILERVERS$cxxMinor"
      if [ "$cxxPatch" != "x" ] ; then
         COMPILERVERS="$COMPILERVERS$cxxPatch"
      fi
   fi
fi

rm -f ${COMPILEDATA}.tmp

echo "/* This file is automatically generated */" > ${COMPILEDATA}.tmp
echo "#define BUILD_ARCH \"$ARCH\"" >> ${COMPILEDATA}.tmp
echo "#define BUILD_NODE \""`uname -a`"\"" >> ${COMPILEDATA}.tmp
echo "#define CXX \"$BXX\"" >> ${COMPILEDATA}.tmp
echo "#define COMPILER \""`type -path $CXX`"\"" >> ${COMPILEDATA}.tmp
echo "#define COMPILERVERS \"$COMPILERVERS\"" >> ${COMPILEDATA}.tmp
if [ "$CUSTOMSHARED" = "" ]; then
   echo "#define MAKESHAREDLIB  \"cd \$BuildDir ; $BXX -c \$Opt $CXXFLAGS \$IncludePath \$SourceFiles ; $BXX \$ObjectFiles $SOFLAGS $LDFLAGS $EXPLLINKLIBS -o \$SharedLib\"" >> ${COMPILEDATA}.tmp
else
   echo "#define MAKESHAREDLIB \"$CUSTOMSHARED\"" >> ${COMPILEDATA}.tmp
fi
if [ "$CUSTOMEXE" = "" ]; then
   echo "#define MAKEEXE \"cd \$BuildDir ; $BXX -c $OPT $CXXFLAGS \$IncludePath \$SourceFiles; $BXX \$ObjectFiles $LDFLAGS -o \$ExeName \$LinkedLibs $SYSLIBS\""  >> ${COMPILEDATA}.tmp
else
   echo "#define MAKEEXE \"$CUSTOMEXE\"" >> ${COMPILEDATA}.tmp
fi
echo "#define CXXOPT \"$CXXOPT\"" >> ${COMPILEDATA}.tmp
echo "#define CXXDEBUG \"$CXXDEBUG\"" >> ${COMPILEDATA}.tmp
echo "#define ROOTBUILD \"$ROOTBUILD\"" >> ${COMPILEDATA}.tmp
echo "#define LINKEDLIBS \"-L$LIBDIR $ROOTLIBS $RINTLIBS \""  >> ${COMPILEDATA}.tmp
echo "#define INCLUDEPATH \"-I$INCDIR\"" >> ${COMPILEDATA}.tmp
echo "#define OBJEXT \"o\"" >> ${COMPILEDATA}.tmp
echo "#define SOEXT \"$SOEXT\"" >> ${COMPILEDATA}.tmp

(
if [ -r $COMPILEDATA ]; then
   diff ${COMPILEDATA}.tmp $COMPILEDATA > /dev/null; status=$?;
   if [ "$status" -ne "0" ]; then
      echo "Running $0"
      echo "Changing $COMPILEDATA"
      mv ${COMPILEDATA}.tmp $COMPILEDATA;
   else
      rm -f ${COMPILEDATA}.tmp; fi
else
   echo "Running $0"
   echo "Making $COMPILEDATA"
   mv ${COMPILEDATA}.tmp $COMPILEDATA; fi
)

exit 0
