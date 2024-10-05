# docker-packer

[![github-actions](https://github.com/theohbrothers/docker-packer/actions/workflows/ci-master-pr.yml/badge.svg?branch=master)](https://github.com/theohbrothers/docker-packer/actions/workflows/ci-master-pr.yml)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/docker-packer?style=flat-square)](https://github.com/theohbrothers/docker-packer/releases/)
[![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/docker-packer/latest)](https://hub.docker.com/r/theohbrothers/docker-packer)

Dockerized [`packer`](https://github.com/hashicorp/packer) with useful tools.

## Tags

| Tag | Dockerfile Build Context |
|:-------:|:---------:|
| `:1.11.2-sops-ubuntu-22.04`, `:latest` | [View](variants/1.11.2-sops-ubuntu-22.04) |
| `:1.11.2-sops-qemu-ubuntu-22.04` | [View](variants/1.11.2-sops-qemu-ubuntu-22.04) |
| `:1.11.2-sops-virtualbox-7.0.20-ubuntu-22.04` | [View](variants/1.11.2-sops-virtualbox-7.0.20-ubuntu-22.04) |
| `:1.11.2-sops-virtualbox-7.1.2-ubuntu-22.04` | [View](variants/1.11.2-sops-virtualbox-7.1.2-ubuntu-22.04) |
| `:1.7.7-sops-ubuntu-20.04` | [View](variants/1.7.7-sops-ubuntu-20.04) |
| `:1.7.7-sops-qemu-ubuntu-20.04` | [View](variants/1.7.7-sops-qemu-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-7.0.20-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-7.0.20-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-7.0.8-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-7.0.8-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-6.1.44-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.44-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-6.1.40-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.40-ubuntu-20.04) |
| `:1.7.7-sops-virtualbox-6.1.26-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.26-ubuntu-20.04) |
| `:1.7.7-sops-qemu-ubuntu-18.04` | [View](variants/1.7.7-sops-qemu-ubuntu-18.04) |
| `:1.7.7-sops-virtualbox-6.0.24-ubuntu-18.04` | [View](variants/1.7.7-sops-virtualbox-6.0.24-ubuntu-18.04) |
| `:1.7.7-sops-virtualbox-5.2.44-ubuntu-16.04` | [View](variants/1.7.7-sops-virtualbox-5.2.44-ubuntu-16.04) |

## Usage

Packer [configuration](https://developer.hashicorp.com/packer/docs/configure#configuring-packer) can be done via `.packerconfig` config file or environment variables (e.g. `PACKER_LOG=1` for verbose logging). Environment variables are preferred when using docker.

### QEMU builder

```sh
# Note: The GID of the group 'kvm' in the container must match the host's. If not, use --privileged instead of --device. See: https://stackoverflow.com/questions/48422001/how-to-launch-qemu-kvm-from-inside-a-docker-container
docker run --rm -it \
    --device /dev/kvm \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.11.2-sops-qemu-ubuntu-22.04 packer build template.json
```

See examples:

- [Ubuntu 20.04 VM `.qcow2` image](docs/examples/ubuntu2004-qemu)

### Virtualbox builder

The host may need to have an exact matching virtualbox version, or at least the same virtualbox minor version, if not virtualbox may not be able to start VMs. To verify virtualbox can start VMs, run the following, ensuring there is no error message:

```sh
docker run --rm -it \
    --device /dev/vboxdrv \
    theohbrothers/docker-packer:1.11.2-sops-virtualbox-7.0.20-ubuntu-22.04 vboxmanage --version
```

If all is well, to build a VM image:

```sh
docker run --rm -it \
    --device /dev/vboxdrv \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.11.2-sops-virtualbox-7.0.20-ubuntu-22.04 packer build template.json
```

See examples:

- [Ubuntu 20.04 VM `.ova`](docs/examples/ubuntu2004-virtualbox)

### Other builder(s)

```sh
docker run --rm -it \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.11.2-sops-ubuntu-22.04 packer build template.json
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
