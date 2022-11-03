# docker-packer

[![github-actions](https://github.com/theohbrothers/docker-packer/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/docker-packer/actions)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/docker-packer?style=flat-square)](https://github.com/theohbrothers/docker-packer/releases/)
[![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/docker-packer/latest)](https://hub.docker.com/r/theohbrothers/docker-packer)

Dockerized [`packer`](https://github.com/hashicorp/packer) with useful tools.

## Tags

| Tag | Dockerfile Build Context |
|:-------:|:---------:|
| `:1.7.7-sops-ubuntu-20.04`, `:latest` | [View](variants/1.7.7-sops-ubuntu-20.04 ) |
| `:1.7.7-sops-virtualbox-7.0.2-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-7.0.2-ubuntu-20.04 ) |
| `:1.7.7-sops-virtualbox-6.1.40-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.40-ubuntu-20.04 ) |
| `:1.7.7-sops-virtualbox-6.1.26-ubuntu-20.04` | [View](variants/1.7.7-sops-virtualbox-6.1.26-ubuntu-20.04 ) |
| `:1.7.7-sops-virtualbox-6.0.24-ubuntu-18.04` | [View](variants/1.7.7-sops-virtualbox-6.0.24-ubuntu-18.04 ) |
| `:1.7.7-sops-virtualbox-5.2.44-ubuntu-16.04` | [View](variants/1.7.7-sops-virtualbox-5.2.44-ubuntu-16.04 ) |


## Usage


```sh
docker run --rm -it \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.7.7-sops-ubuntu-20.04 sh -c 'packer --version && packer build .'

# virtualbox
# The host must have an exact matching virtualbox version, in this case, virtualbox 6.1.26
docker run --rm -it \
    -v /dev/vboxdrv:/dev/vboxdrv:ro \
    -v $(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:1.7.7-sops-virtualbox-6.1.26-ubuntu-20.04 sh -c 'packer --version && vboxmanage --version && packer build .'
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
