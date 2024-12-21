# A blocklist for Transmission & others

![Dynamic badge with number of ranges block](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgithub.com%2Fcolindean%2Ftransmission-blocklist%2Freleases%2Flatest%2Fdownload%2Fstats.json&query=%24.range_count&label=IP%20ranges%20blocked)

![Dynamic badge with GitHub Release Date](https://img.shields.io/github/release-date/colindean/transmission-blocklist)
![Dynamic badge with GitHub Release](https://img.shields.io/github/v/release/colindean/transmission-blocklist)
![Dynamic badge with CalVer scheme: YYYY.MM.DD.beat--hash](https://img.shields.io/badge/CalVer-YYYY.MM.DD.beat--hash-22bfda.svg)
![Dynamic badge with GitHub License](https://img.shields.io/github/license/colindean/transmission-blocklist)

[![Dynamic badge with Build Blocklist action status](https://github.com/colindean/transmission-blocklist/actions/workflows/blocklist.yml/badge.svg)](https://github.com/colindean/transmission-blocklist/actions/workflows/blocklist.yml)
![Dynamic badge with GitHub commit activity](https://img.shields.io/github/commit-activity/y/colindean/transmission-blocklist)

This repo uses GitHub Actions to assemble a comprehensive [P2P-format blocklist][p2p] weekly and publish it when it differs from the previous release.
It is usable in Transmission, PeerGuardian, Bluetack, Vuze, ProtoWall, Deluge, KTorrent, and probably more software.
See `build-blocklist.sh` for sources.

[p2p]: https://en.wikipedia.org/wiki/PeerGuardian#P2P_plaintext_format "PeerGuardian's P2P format"

## Use

> [!TIP]
> Always use `latest` if you want automatic updates.
> Versions are CalVer as noted above.
> I'm unaware of any blocklist consumer that can automatically update CalVer/SemVer-versioned blocklist artifacts
> by detecting GitHub Releases version changes.

Set `https://github.com/colindean/transmission-blocklist/releases/latest/download/blocklist.gz` for your blocklist URL
and enable automatic updates.

### Configuring Transmission

> [!NOTE]
> Transmission is the _only_ client I use, so it is the only one officially supported.

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

See [the Transmission blocklist docs](https://github.com/transmission/transmission/blob/main/docs/Blocklists.md) for more info.

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
