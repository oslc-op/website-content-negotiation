#!/usr/bin/env bash
# set -x
set -eEuo pipefail

if [ -t 1 ]; then
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    reset=$(tput sgr0)
else
    red=""
    green=""
    reset=""
fi

URI_BASE="http://localhost:3000"
if getopts "p" arg; then
    URI_BASE="http://open-services.net"
    echo "${green}Running production tests${reset}"
else
    echo "${red}Running tests locally${reset}"
fi

function cleanup_on_exit {
    echo "${red}SOME TESTS FAILED${reset}"
}
trap cleanup_on_exit ERR


function test_ns() {
    echo "Running tests on '$1'"
    curl -s --fail-with-body -H "Accept: text/turtle" -L "${URI_BASE}/$1" > /dev/null || { echo "Failed while getting Turtle for ${URI_BASE}/$1"; exit 1; }
    curl -s --fail-with-body -H "Accept: application/rdf+xml" -L "${URI_BASE}/$1" > /dev/null || { echo "Failed while getting RDF/XML for ${URI_BASE}/$1"; exit 1; }
    curl -s --fail-with-body -H "Accept: application/n-triples" -L "${URI_BASE}/$1" > /dev/null || { echo "Failed while getting N-Triples for ${URI_BASE}/$1"; exit 1; }
    curl -s --fail-with-body -H "Accept: application/ld+json" -L "${URI_BASE}/$1" > /dev/null || { echo "Failed while getting JSON-LD for ${URI_BASE}/$1"; exit 1; }
    curl -s --fail-with-body --compressed -H "Accept: text/turtle;q=1.0,application/rdf+xml;q=0.8,application/n-triples;q=0.2,application/ld+json;q=0.1" -L "${URI_BASE}/$1" > /dev/null || { echo "Failed while getting any RDF via conneg for ${URI_BASE}/$1"; exit 1; }
    curl -s --fail-with-body -H "Accept: text/html;q=1.0,text/*;q=0.8" -L "${URI_BASE}/$1" > /dev/null || { echo "Failed while getting HTML for ${URI_BASE}/$1"; exit 1; }
}

test_ns "ns/core"
test_ns "ns/core/shapes/3.0"
test_ns "ns/cm"
test_ns "ns/cm/shapes/3.0"
test_ns "ns/rm"
test_ns "ns/rm/shapes/2.1"
test_ns "ns/qm"
test_ns "ns/qm/shapes/2.1"
test_ns "ns/config"
test_ns "ns/am"
test_ns "ns/asset"
test_ns "ns/auto"
test_ns "ns/perfmon"
test_ns "ns/promcode"
test_ns "ns/promcode/shapes/1.0"

echo "${green}ALL TESTS PASSED${reset}"