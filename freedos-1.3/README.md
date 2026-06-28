# FreeDOS 1.3

Builds an `x86/freedos-1.3` template: a bootable FreeDOS 1.3 C: drive with the
**Full** package set (BASE + apps/bonus). Runs on the `windows-9x` profile
(i440fx/SeaBIOS, Cirrus VGA, IDE, AMD PCnet); shows in `vmlab template list` as
`x86/freedos-1.3` (it runs on the x86_64 emulator).

Unlike the proprietary `dos-6.22` entry, FreeDOS is FOSS / freely
redistributable, so this template carries a `registry` and is **publishable** to
GHCR (`just freedos-push`).

## How it works

This is a setup-driven install with no answer file — FreeDOS predates that and
has no QEMU guest agent, so the build drives the official **FDI** batch installer
over the live screen (VNC + OCR), the same way `dos-6.22` is built.

- `fetch-deps.sh` downloads the official `FD13-LiveCD.zip`, sha256-verifies it,
  and extracts `FD13LIVE.iso` (gitignored). vmlab's URL sources can't unpack the
  multi-file zip, hence the script.
- `scripts/install.ws` boots the LiveCD, drives FDI through language → welcome →
  auto-partition (which forces a reboot) → format → **Full** package set →
  install, then `poweroff`s to seal a bootable C: (FreeDOS has no ACPI, so a clean
  QMP quit is what flushes the qcow2).

## Build

```sh
just freedos-build           # runs fetch-deps.sh, then builds; idempotent
# or directly:
cd freedos-1.3 && ./fetch-deps.sh && vmlab template build
```

## Publish

FreeDOS is redistributable, so the built template can be pushed (authenticate
once with `vmlab template login`):

```sh
just freedos-push            # -> ghcr.io/vmlabdev/vmlab-templates/freedos-1.3:1.3
```

## Bumping the version

Update `SHA256`/`URL` in `fetch-deps.sh` (sums in the release's `verify.txt` on
ibiblio) and `version` in `vmlab.wcl`.
