# Wf4Ever prototype1 test script configuration
#
# Use bash source to include this
#
# Assume that Jena ARQ command line tools installed: 
#   see http://openjena.org/ARQ/cmds.html
#   see http://sourceforge.net/projects/jena/files/ARQ/
#

ARQROOT="./ARQ-2.8.7/"
#DropBoxDir="./data"
DropBoxDir="/usr/workspace/prototype1-testsuite/ROSRS_DropBox/Dropbox/prototype1-testsuite"

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
    ${ARQROOT}/bin/arq --data=$1 --query= "$2" --results=JSON | grep -q "\"boolean\" : true"
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