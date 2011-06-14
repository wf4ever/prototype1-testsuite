#!/bin/bash
#
# Remove test RO directories
#

source TestConfig.sh

# Some tests to avoid potential diaster if environment is not set up properly

if [[ "${DropBoxDir}" == "" ]] ; then
    echo "No definition for DropBox directory"
    exit 1
fi

if [[ ! -e ${DropBoxDir}/ROBox-test-directory ]] ; then
    echo "No sentinel file in DropBox directory"
    exit 1
fi

# Now delete test directories

rm -rfv ${DropBoxDir}/TestRO*

# remove temporary files in working directory

# rm -v TestRO*-manifest.rdf
rm -v TestRO*-manifest-query.sparql

# End.
