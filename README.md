# docker-packer

[![github-actions](https://github.com/theohbrothers/docker-packer/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/docker-packer/actions)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/docker-packer?style=flat-square)](https://github.com/theohbrothers/docker-packer/releases/)
[![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/docker-packer/latest)](https://hub.docker.com/r/theohbrothers/docker-packer)

Dockerized [`packer`](https://github.com/hashicorp/packer) with useful tools.

## Tags

| Tag | Dockerfile Build Context |
|:-------:|:---------:|
| `:1.7.7-sops-ubuntu-20.04`, `:latest` | [View](variants/1.7.7-sops-ubuntu-20.04) |
| `:1.7.7-sops-qemu-ubuntu-20.04` | [View](variants/1.7.7-sops-qemu-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-7.0.8-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-7.0.8-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-6.1.44-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.44-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-6.1.40-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.40-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-6.1.26-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.26-ubuntu-20.04) |
| `:1.7.7-sops-qemu-ubuntu-18.04` | [View](variants/1.7.7-sops-qemu-ubuntu-18.04) |
| `:1.7.7-sops-virtualbox-6.0.24-ubuntu-18.04` | [View](variants/1.7.7-sops-virtualbox-6.0.24-ubuntu-18.04) |
| `:1.7.7-sops-virtualbox-5.2.44-ubuntu-16.04` | [View](variants/1.7.7-sops-virtualbox-5.2.44-ubuntu-16.04) |

## Usage

### QEMU builder

```sh
# Note: The GID of the group 'kvm' in the container must match the host's. If not, use --privileged instead of --device. See: https://stackoverflow.com/questions/48422001/how-to-launch-qemu-kvm-from-inside-a-docker-container
docker run --rm -it \
    --device /dev/kvm \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.7.7-sops-qemu-ubuntu-20.04 sh -c 'packer --version && packer build template.json'
```

See docker-compose examples:

- [Ubuntu 20.04 VM image](docs/examples/ubuntu2004-qemu)

### Virtualbox builder

```sh
# Note: The host may need to have an exact matching virtualbox version, or at least the same virtualbox minor version,
# if not virtualbox may not be able to start VMs
docker run --rm -it \
    --device /dev/vboxdrv \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.7.7-sops-virtualbox-7.0.8-ubuntu-20.04 sh -c 'packer --version && vboxmanage --version && packer build template.json'
```

See docker-compose examples:

- [Ubuntu 20.04 VM .ova](docs/examples/ubuntu2004-virtualbox)

### Other builder(s)

```sh
docker run --rm -it \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.7.7-sops-ubuntu-20.04 sh -c 'packer --version && packer build template.json'
```

## Development

Requires Windows `powershell` or [`pwsh`](https://github.com/PowerShell/PowerShell).

```powershell
# Install Generate-DockerImageVariants module: https://github.com/theohbrothers/Generate-DockerImageVariants
Install-Module -Name Generate-DockerImageVariants -Repository PSGallery -Scope CurrentUser -Force -Verbose

# Edit ./generate templates

# Generate the variants
Generate-DockerImageVariants .
```
