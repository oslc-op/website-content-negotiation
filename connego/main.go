package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
    "path/filepath"
    "strings"

    "gopkg.in/yaml.v3"
)

type FileMap struct {
    RDFXML   string `yaml:"rdfxml"`
    NTriples string `yaml:"ntriples"`
    JSONLD   string `yaml:"jsonld"`
    Turtle   string `yaml:"turtle"`
}

type NSDef struct {
    Prefix      string  `yaml:"prefix"`
    CoreVersion string  `yaml:"core_version"`
    HtmlURI     string  `yaml:"html_uri"`
    Files       FileMap `yaml:"files"`
}

type Config struct {
    BaseDir      string   `yaml:"base_dir"`
    Compression  bool     `yaml:"compression"`
    NSDefinitions []NSDef `yaml:"ns_definitions"`
}

func main() {
    // Load YAML config
    f, err := os.Open("../config/conneg.yml")
    if err != nil {
        log.Fatalf("Failed to open config: %v", err)
    }
    defer f.Close()
    var config Config
    if err := yaml.NewDecoder(f).Decode(&config); err != nil {
        log.Fatalf("Failed to parse YAML: %v", err)
    }

    for _, ns := range config.NSDefinitions {
        ns := ns // capture range variable
        http.HandleFunc(ns.Prefix, func(w http.ResponseWriter, r *http.Request) {
            accept := r.Header.Get("Accept")
            var contentType, filePath string

            switch {
            case strings.Contains(accept, "application/ld+json"):
                contentType = "application/ld+json"
                filePath = ns.Files.JSONLD
            case strings.Contains(accept, "text/turtle"):
                contentType = "text/turtle"
                filePath = ns.Files.Turtle
            case strings.Contains(accept, "application/rdf+xml"):
                contentType = "application/rdf+xml"
                filePath = ns.Files.RDFXML
            case strings.Contains(accept, "application/n-triples"):
                contentType = "application/n-triples"
                filePath = ns.Files.NTriples
            case strings.Contains(accept, "text/html"):
                http.Redirect(w, r, ns.HtmlURI, http.StatusSeeOther)
                return
            default:
                http.Error(w, "Not Acceptable", http.StatusNotAcceptable)
                return
            }

            if ns.CoreVersion != "" {
                w.Header().Set("OSLC-Core-Version", ns.CoreVersion)
            }
            w.Header().Set("Content-Type", contentType)
            fullPath := filepath.Join(config.BaseDir, filePath)
            http.ServeFile(w, r, fullPath)
        })
    }

    fmt.Println("OSLC content negotiation listening on 127.0.0.1:3000")
    log.Fatal(http.ListenAndServe("127.0.0.1:3000", nil))
}