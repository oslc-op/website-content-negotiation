var express = require('express');
var app = express();

var baseDir = '/var/www/oslc.co/public/ns/';

// base of the URI that gets prepended to the redirects
// var baseURI = 'https://open-services.net/ns/';
var baseURI = '/ns/';

// just a map to avoid repeating constants
const extMap = {
    'application/ld+json': '.jsonld',
    'text/turtle': '.ttl',
    'application/rdf+xml': '.rdf',
    'application/n-triples': '.nt',
}

function serveNeg(specName, htmlRedir) {
    return function (req, res) {
        // the order is important; it will be used unless the client uses q-values
        var rdfType = req.accepts(["application/ld+json", "text/turtle", "application/rdf+xml", 'application/n-triples', "text/html"]);
        console.log(rdfType);
        if (rdfType === "text/html") {
            res.redirect(303, htmlRedir);
        } else if(rdfType) {
            // we can either do a 303 redirect OR send the file
            // res.redirect(303, baseURI + specName + extMap[rdfType]);
            res.sendFile(specName + extMap[rdfType], { root: baseDir });
        } else {
            res.status(406).send();
        }
    };
}

app.get('/ns/core', serveNeg('core/core', 'https://archive.open-services.net/wiki/core/CoreVocabulary/index.html'));

app.get('/ns/config', serveNeg('config/config-vocab', 'https://oslc-op.github.io/oslc-specs/specs/config/config-vocab.html'));

app.get('/ns/cm', serveNeg('cm/cm', 'https://archive.open-services.net/bin/view/Main/CmVocabulary.html'));

app.get('/ns/rm', serveNeg('rm/requirements-management-vocab', 'https://archive.open-services.net/bin/view/Main/RmVocabulary.html'));

app.get('/ns/qm', serveNeg('qm/qm', 'https://archive.open-services.net/bin/view/Main/QmVocabulary.html'));

app.get('/ns/am', serveNeg('am/am', 'https://archive.open-services.net/wiki/architecture-management/OSLC-Architecture-Management-Vocabulary/index.html'));

app.get('/ns/asset', serveNeg('asset/asset', 'https://archive.open-services.net/wiki/asset-management/OSLC-Asset-Management-Vocabulary/index.html'));

app.get('/ns/auto', serveNeg('auto/automation-vocab', 'https://archive.open-services.net/wiki/automation/OSLC-Automation-Vocabulary/index.html'));

app.get('/ns/perfmon', serveNeg('perfmon/performance-monitoring-vocab', 'https://archive.open-services.net/wiki/performance-monitoring/OSLC-Performance-Monitoring-Vocabulary/index.html'));

app.get('/ns/ems', serveNeg('ems/ems', 'https://archive.open-services.net/wiki/estimation-and-measurement/EMS-1.0-REST-API-Data-Model/index.html'));

app.listen(3000, function () {
    console.log('OSLC content negotiation listening on port 3000!');
});
