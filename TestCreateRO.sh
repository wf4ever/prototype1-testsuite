# !/bin/bash
#
# Test creation of research object
#
# Exit status:
#  0: success
#  1: failure
#  anything else is some other error
#
# Prerequisites:
#   ${DropBoxDir}
#       connects via DropBox to a storage area that is being monitored by
#       the RO SRS DropBox interface shim.  Defined in TestConfig.sh.
#   ARQ-2.8.7
#       for SparQL queries over manifest

#@@TODO remove this?
export ARQROOT=$(pwd)/ARQ-*/

#@@TODO more intelligent wait logic
#@@TODO clean up temporary manifest and query files
#@@TODO fix up query function
#@@ TODO factor out elements that should be common across test cases

# ----------------------------------------------------------------

echo "TestCreateRO - START: Test create RO"

source TestConfig.sh

# Generate unique name for RO

if (type -P uuidgen 2>/dev/null >/dev/null); then 
    RO="TestRO$(uuidgen)"
else 
    RO="TestRO$$"
fi

# ----------------------------------------------------------------

echo " - Create local RO instance ${RO} in ${DropBoxDir}"

mkdir -p ${DropBoxDir}/${RO}

cat >${DropBoxDir}/${RO}/README.txt - <<END
RO created by TestCreateRO.sh for ROBox testing
END

# Expected initial manifest @@TODO is this really required?
cat >${RO}-manifest.rdf - <<END
<?xml version="1.0" encoding="utf-8"?>
<rdf:RDF
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:oxds="http://vocab.ox.ac.uk/dataset/schema#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
>
  <oxds:Grouping>
    <dcterms:identifier>${RO}</dcterms:identifier>
    <dcterms:description>Description of ${RO}</dcterms:description>
    <dcterms:title>Test research object ${RO}</dcterms:title>
    <dcterms:creator>prototype1-testsuite</dcterms:creator>
  </oxds:Grouping>
</rdf:RDF>
END

cat >${RO}-manifest-query.sparql - <<END
prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
prefix dcterms: <http://purl.org/dc/terms/>
prefix oxds:    <http://vocab.ox.ac.uk/dataset/schema#>
ASK { ?s dcterms:identifier "${RO}" }
END

# Don't do this:  RObox should create the manifest
# cp ${RO}-manifest.rdf ${DropBoxDir}/${RO}/manifest.rdf

# ----------------------------------------------------------------

echo " - Waiting for SRS to create RO and metadata"

sync_RO_SRS

sleep 15

# ----------------------------------------------------------------

echo " - Look for manifest with SRS metadata"

if [ ! -e ${DropBoxDir}/${RO}/manifest.rdf ] ; then
    echo "TestCreateRO - FAIL: manifest.rdf not created"
    exit 1
else
    # test new manifest contents
    if ! arq_query_ask ${DropBoxDir}/${RO}/manifest.rdf ${RO}-manifest-query.sparql ; then
        echo "TestCreateRO - FAIL: manifest wrong id"
        exit 1
    fi
fi

# ----------------------------------------------------------------

echo "TestCreateRO - SUCCESS"
exit 0

# End.
