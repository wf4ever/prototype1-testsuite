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

# ----------------------------------------------------------------

echo "TestROAddData - START: Test create RO and add data to it"

source TestConfig.sh

# DropBoxDir    is location where ROs are created
# RO            is set to name for new RO

# ----------------------------------------------------------------

echo " - Create local RO instance ${RO} in ${DropBoxDir}"

mkdir -p ${DropBoxDir}/${RO}

cat >${DropBoxDir}/${RO}/README.txt - <<END
RO created by TestROAddData.sh for ROBox testing
$(date)
END

sleep 2

# ----------------------------------------------------------------

echo " - Request SRS to create RO ${RO} and metadata"
sync_RO_SRS

echo -n "  Waiting for RO metadata to be created..."
wait_for_manifest_rdf

# ----------------------------------------------------------------

echo " - Look for manifest with SRS metadata"

cat >${RO}-manifest-query.sparql - <<END
prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
prefix dcterms: <http://purl.org/dc/terms/>
prefix oxds:    <http://vocab.ox.ac.uk/dataset/schema#>
ASK { ?s dcterms:identifier "${RO}" }
END

if [ ! -e ${DropBoxDir}/${RO}/manifest.rdf ] ; then
    echo "TestROAddData - FAIL: manifest.rdf not created"
    exit 1
else
    # test new manifest contents
    if ! arq_query_ask ${DropBoxDir}/${RO}/manifest.rdf ${RO}-manifest-query.sparql ; then
        echo "TestROAddData - FAIL: manifest wrong id"
        exit 1
    fi
fi

# ----------------------------------------------------------------

echo " - Add new data to RO"

cat >${DropBoxDir}/${RO}/AddData.txt - <<END
RO data added by TestROAddData.sh for ROBox testing
$(date)
END

sleep 2

# ----------------------------------------------------------------

echo " - Request SRS to re-sync RO ${RO} and metadata"
sync_RO_SRS

# ----------------------------------------------------------------

echo -n "  waiting for data to show in manifest..."

cat >${RO}-manifest-query.sparql - <<END
prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
prefix dcterms: <http://purl.org/dc/terms/>
prefix oxds:    <http://vocab.ox.ac.uk/dataset/schema#>
prefix ore:     <http://www.openarchives.org/ore/terms/>
ASK { ?s ore:aggregates ?f . FILTER regex(str(?f), "http://.*ROs/${RO}/v1/AddData.txt") }
END

for countdown in 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1; do
    echo -n " $countdown"
    sleep 1
    arq_query_ask ${DropBoxDir}/${RO}/manifest.rdf ${RO}-manifest-query.sparql
    queryok=$?
    echo -n ":$queryok"
    if [ "$queryok" == "0" ] ; then break ; fi
done
echo "."

# test new manifest contents
if [ "$queryok" != "0" ] ; then
    echo "TestROAddData - FAIL: manifest not showing new data"
    exit 1
fi

# ----------------------------------------------------------------

# Clean up and exit
rm ${RO}-manifest-query.sparql
rm -rf ${DropBoxDir}/${RO}
echo "TestROAddData - SUCCESS"
exit 0

# End.
