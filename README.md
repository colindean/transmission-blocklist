# A blocklist for Transmission & others

![Dynamic badge with number of ranges block](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgithub.com%2Fcolindean%2Ftransmission-blocklist%2Freleases%2Flatest%2Fdownload%2Fstats.json&query=%24.range_count&label=IP%20ranges%20blocked)


![Dynamic badge with GitHub Release Date](https://img.shields.io/github/release-date/colindean/transmission-blocklist)
![Dynamic badge with GitHub Release](https://img.shields.io/github/v/release/colindean/transmission-blocklist)
![Dynamic badge with GitHub License](https://img.shields.io/github/license/colindean/transmission-blocklist)

[![Dynamic badge with Build Blocklist action status](https://github.com/colindean/transmission-blocklist/actions/workflows/blocklist.yml/badge.svg)](https://github.com/colindean/transmission-blocklist/actions/workflows/blocklist.yml)
![Dynamic badge with GitHub commit activity](https://img.shields.io/github/commit-activity/y/colindean/transmission-blocklist)


This repo uses GitHub Actions to assemble and publish a comprehensive IP blocklist weekly.
See `build-blocklist.sh` for sources.

## Use

Set `https://github.com/colindean/transmission-blocklist/releases/latest/download/blocklist.gz` in your Transmission settings.

> [!TIP]
> Always use `latest` if you want automatic updates.
> Versions are CalVer+hash and not meaningful, plus…
> I'm unaware of any blocklist consumer that can automatically update CalVer/SemVer-versioned blocklist artifacts.

Add to Transmission's `settings.json`:

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
**Blocklists keep you safe from bad actors, even when you're just seeding open source software like I am.**

## History

This is based on [`guillehorno/transmission-blocklist`](https://github.com/guillehorno/transmission-blocklist),
which is based on [shmup's blocklist generator](https://gist.github.com/shmup/29566c5268569069c256).

This bears a lot of resemblance to [`Naunter/BT_BlockLists`](https://github.com/Naunter/BT_BlockLists),
but isn't based on it.
We got ideas from the same places and once discovering it, I've used some its ideas :wink:
