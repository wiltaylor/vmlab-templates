# rocky-9

Rocky Linux 9 built from the official GenericCloud qcow2 with a NoCloud
cloud-init seed.

- Credentials: `vmlab` / `vmlab` (passwordless sudo via wheel), SSH
  password auth on.
- QEMU guest agent installed and enabled.
- To bump: take the qcow2 URL and sha256 from the `CHECKSUM` file under
  <https://download.rockylinux.org/pub/rocky/9/images/x86_64/> and update
  `vmlab.wcl`.

```sh
vmlab template build
```
