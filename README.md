# blocklist for transmission

[![Build Status](https://travis-ci.org/colindean/transmission-blocklist.svg?branch=master)](https://travis-ci.org/colindean/transmission-blocklist)

This script will update a blocklist

## Use

Set `https://github.com/colindean/transmission-blocklist/releases/latest/download/blocklist.gz` in your Transmission settings.

Add to settings.json:

```json
"blocklist-enabled": true,
"blocklist-url": "https://github.com/colindean/transmission-blocklist/releases/latest/download/blocklist.gz",
```

Verify that it's configured correctly with the `transmission-remote` command or whatever is appropriate for how you use Transmission:

```
$ transmission-remote -n admin:password --blocklist-update
localhost:9091/transmission/rpc/ responded: "success"
```

## Updates

This is provided without any warranty or suitability or guarantee of updates if you use the `latest` release functionality of GitHub Releases to retrieve the latest release regularly.
Any breakage is not my fault nor the fault of GitHub, whatever CI is used to automate builds, or any authors past or present of this software.
Blocklists keep you safe from bad actors, even when you're just seeding open source software like I am.
