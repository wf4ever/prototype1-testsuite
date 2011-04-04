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
#       the RO SRS DropBox interface shim
#

echo "TestCreateRO - START: Test create RO"

source TestConfig.sh

echo " - Create local RO instance"

mkdir -p ${DropBoxDir}/TestRO1

# Expected initial manifest @@TODO is this really required?
cat >TestRO1-manifest.rdf - <<END
<?xml version="1.0" encoding="utf-8"?>
<rdf:RDF
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:oxds="http://vocab.ox.ac.uk/dataset/schema#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
>
  <oxds:Grouping>
    <dcterms:identifier>TestRO1</dcterms:identifier>
    <dcterms:description>Description of TestRO1</dcterms:description>
    <dcterms:title>Test research object TestRO1</dcterms:title>
    <dcterms:creator>prototype1-testsuite</dcterms:creator>
  </oxds:Grouping>
</rdf:RDF>
END

cat >TestRO1-manifest-query.sparql - <<END
prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
prefix dcterms: <http://purl.org/dc/terms/>
prefix oxds:    <http://vocab.ox.ac.uk/dataset/schema#>
ASK { ?s dcterms:identifier "TestRO1" }
END

# Don't do this:  RObox should create the manifest
# cp TestRO1-manifest.rdf ${DropBoxDir}/TestRO1/manifest.rdf

echo " - Waiting for SRS to create RO and metadata"
sleep 5

echo " - Look for manifest with SRS metadata"

if [ ! -e ${DropBoxDir}/TestRO1/manifest.rdf ] ; then
    echo "TestCreateRO - FAIL: manifest.rdf not created"
    exit 1
else
    # test new manifest contents
    if ! arq_query_ask ${DropBoxDir}/TestRO1/manifest.rdf TestRO1-manifest-query.sparql ; then
        echo "TestCreateRO - FAIL: manifest wrong id"
        exit 1
    fi
fi

echo "TestCreateRO - SUCCESS"
exit 0

# End.
