# Wf4Ever prototype1 test script configuration
#
# Use bash source to include this
#
# Assume that Jena ARQ command line tools installed: 
#   see http://openjena.org/ARQ/cmds.html
#   see http://sourceforge.net/projects/jena/files/ARQ/
#

export ARQROOT=$(pwd)/ARQ-2.8.7

DropBoxDir="/usr/workspace/prototype1-testsuite/ROSRS_DropBox/Dropbox/prototype1-testsuite"

# Check we've got the right directory
if [[ ! -e ${DropBoxDir}/ROBox-test-directory ]] ; then
    echo "No sentinel file in DropBox directory: is DropBoxDir set correctly in TestConfig.sh?"
    exit 1
fi

# Generate unique name for RO
if (type -P uuidgen 2>/dev/null >/dev/null); then 
    uuid=$(uuidgen)
    RO="TestRO-${uuid:0:4}"
else 
    RO="TestRO-$$"
fi

# Test Sandbox for ROBox at http://calatola.man.poznan.pl/robox
#
# Displayed at http://calatola.man.poznan.pl/robox/dashboard/dropbox:
#   ROBox ID:	 http://calatola.man.poznan.pl/robox/dropbox_accounts/1/ro_containers/2
#   Path in Dropbox:	 prototype1-testsuite
#   Workspace ID (for ROSRS):	 dbox-pS6ZaRFtSoW0TRBQI5AElg
#   Workspace Password (for ROSRS):	 d41d8cd98f00b204e9800998ecf8427e
#
# Perform SPARQL ASK query against RDF file
#
#   $1: data file
#   $2: query file
#
# Exit status 0 if ASK query returns true
#
function arq_query_ask ()
{
    #echo "File $1"
    #echo "Query $2"
    ${ARQROOT}/bin/arq --data=$1 --query="$2" --results=JSON | grep -q "\"boolean\" : true"
    exstatus=$?
    #echo "Result $exstatus"
    return $exstatus
}

# Diagnostic to display result of query
function arq_query_dump ()
{
    echo "File $1"
    echo "Query $2"
    echo "--------"
    ${ARQROOT}/bin/arq --data=$1 --query="$2" --results=JSON
    echo "--------"
    #echo "Result $?"
}

# Synchronize RO SRS with updated DropBox contents
function sync_RO_SRS ()
{
    roboxid="http://calatola.man.poznan.pl/robox/dropbox_accounts/1/ro_containers/2"
    roboxpasswd="d41d8cd98f00b204e9800998ecf8427e"
    curl ${roboxid}/force_sync \
         --data-binary @- -H "Content-Type: application/json" <<____endpostdata
        {
        'password': '${roboxpasswd}'
        }
____endpostdata
}

# Wait for manifest to be created in DropBox directory
function wait_for_manifest_rdf ()
{
    for countdown in 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1; do
        echo -n " $countdown"
        sleep 1
        if [ -e ${DropBoxDir}/${RO}/manifest.rdf ] ; then break ; fi
    done
    echo "."
}

# End.
