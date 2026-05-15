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
    CURL_OPTS=(--retry 3 --retry-delay 7 --retry-all-errors -s --fail-with-body -L)
    
    echo "Running tests on '$1'"
    curl "${CURL_OPTS[@]}" -H "Accept: text/turtle" "${URI_BASE}/$1" > /dev/null || { err=$?; echo "Failed with error code $err while getting Turtle for ${URI_BASE}/$1"; exit $err; }
    curl "${CURL_OPTS[@]}" -H "Accept: application/rdf+xml" "${URI_BASE}/$1" > /dev/null || { err=$?; echo "Failed with error code $err while getting RDF/XML for ${URI_BASE}/$1"; exit $err; }
    curl "${CURL_OPTS[@]}" -H "Accept: application/n-triples" "${URI_BASE}/$1" > /dev/null || { err=$?; echo "Failed with error code $err while getting N-Triples for ${URI_BASE}/$1"; exit $err; }
    curl "${CURL_OPTS[@]}" -H "Accept: application/ld+json" "${URI_BASE}/$1" > /dev/null || { err=$?; echo "Failed with error code $err while getting JSON-LD for ${URI_BASE}/$1"; exit $err; }
    curl "${CURL_OPTS[@]}" --compressed -H "Accept: text/turtle;q=1.0,application/rdf+xml;q=0.8,application/n-triples;q=0.2,application/ld+json;q=0.1" "${URI_BASE}/$1" > /dev/null || { err=$?; echo "Failed with error code $err while getting any RDF via conneg for ${URI_BASE}/$1"; exit $err; }
    curl "${CURL_OPTS[@]}" -H "Accept: text/html;q=1.0,text/*;q=0.8" "${URI_BASE}/$1" > /dev/null || { err=$?; echo "Failed with error code $err while getting HTML for ${URI_BASE}/$1"; exit $err; }
}

test_ns "ns/promcode"
test_ns "ns/promcode/shapes/1.0"
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

echo "${green}ALL TESTS PASSED${reset}"