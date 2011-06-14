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

#@@ TODO factor out elements that should be common across test cases

# ----------------------------------------------------------------

echo "TestCreateRO - START: Test create RO"

source TestConfig.sh

# RO is set to name for new RO

# ----------------------------------------------------------------

echo " - Create local RO instance ${RO} in ${DropBoxDir}"

mkdir -p ${DropBoxDir}/${RO}

cat >${DropBoxDir}/${RO}/README.txt - <<END
RO created by TestCreateRO.sh for ROBox testing
$(date)
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

sleep 2

# ----------------------------------------------------------------

echo " - Request SRS to create RO ${RO} and metadata"
sync_RO_SRS

echo -n "  Waiting for RO metadata to be created..."
wait_for_manifest_rdf

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

rm ${RO}-manifest-query.sparql
echo "TestCreateRO - SUCCESS"
exit 0

# End.
