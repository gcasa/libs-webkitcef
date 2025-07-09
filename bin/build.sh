#!/bin/sh

./bin/download_cef.sh

PROJNAME=`ls -C1 cef_build/cef-project/third_party/cef | grep -v tar`
PROJDIR="cef_build/cef-project/third_party/cef/${PROJNAME}"
LIBDIR="cef_build/cef-project/build/libcef_dll_wrapper"

echo "ADDITIONAL_INCLUDE_DIRS += -I${PROJDIR}/include" >> GNUmakefile.generated
echo "ADDITIONAL_LDFLAGS += -L${LIBDIR}" >> GNUmakefile.generated
echo "ADDITIONAL_GUI_LIBS += -lcef_dll_wrapper" >> GNUmakefile.generated

make debug=yes

exit 0
