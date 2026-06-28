# Windows 2000 Professional (SP4)

Builds `x86/windows-2000`, installed unattended from the bootable SP4 CD.

- `../iso/Windows-2000-Professional-SP4.iso` (gitignored) is the install media.
- `fetch-deps.sh` injects `WINDOWS_2000_PRO_KEY` (from `../.env`) into
  `winnt.sif.in` and builds `./answer/` → an `A:` floppy. CD-boot Setup reads
  `A:\winnt.sif` automatically and runs fully unattended (auto-partition,
  format NTFS, admin password `vmlab`, auto-logon).
- `scripts/install.ws` nudges the one-time boot-CD prompt, then watches the
  screen through text Setup → GUI Setup → desktop and seals with an ACPI
  shutdown.

Runs on the `windows-9x` profile (i440fx/SeaBIOS, Cirrus VGA, IDE, PCnet).
Shows in `vmlab template list` as `x86/windows-2000`.

## Build

```
just windows-2000-build
# or: cd windows-2000 && ./fetch-deps.sh && vmlab template build
```
