# Wf4Ever prototype1 test script configuration
#
# Use bash source to include this
#
# Assume that Jena ARQ command line tools installed: 
#   see http://openjena.org/ARQ/cmds.html
#   see http://sourceforge.net/projects/jena/files/ARQ/
#

ARQROOT="./ARQ-2.8.7/"
DropBoxDir="./data"

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
    #echo "Result $?"
}
