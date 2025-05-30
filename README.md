## Node.js server to handle content negotiation for the OSLC website.

[![Discourse status](https://img.shields.io/discourse/https/meta.discourse.org/status.svg)](https://forum.open-services.net/)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/OSLC/chat)

## Getting started

First, [install Go.](https://go.dev/dl/)

Then, if necessary, adjust `config/conneg.yml` to point to your local copy of https://github.com/oslc-op/website/tree/master/content/ns

Finally, run:

```sh
cd connego
go run ./main.go
```

## Deployment

On the server:

```sh
cd ~/workspace/oslc-site-content-negotiation/connego/
git checkout master
git pull
cd connego
go build -o connego main.go
sudo systemctl daemon-reload
sudo systemctl restart connego
sudo systemctl enable connego
sudo systemctl status connego
```

## Testing

To test the prod endpoint:

    ./test.sh -p

To test the local endpoint:

    ./test.sh
