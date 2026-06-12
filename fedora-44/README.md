# fedora-44

Fedora 44 built from the official Cloud Base Generic qcow2 with a NoCloud
cloud-init seed.

- Credentials: `vmlab` / `vmlab` (passwordless sudo via wheel), SSH
  password auth on.
- QEMU guest agent installed and enabled.
- To bump: take the qcow2 URL and sha256 from the `*-CHECKSUM` file under
  <https://download.fedoraproject.org/pub/fedora/linux/releases/> and
  update `vmlab.wcl`.

```sh
vmlab template build
```
