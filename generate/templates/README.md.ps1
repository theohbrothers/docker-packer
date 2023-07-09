@"
# docker-packer

[![github-actions](https://github.com/theohbrothers/docker-packer/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/docker-packer/actions)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/docker-packer?style=flat-square)](https://github.com/theohbrothers/docker-packer/releases/)
[![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/docker-packer/latest)](https://hub.docker.com/r/theohbrothers/docker-packer)

Dockerized [``packer``](https://github.com/hashicorp/packer) with useful tools.

## Tags

| Tag | Dockerfile Build Context |
|:-------:|:---------:|
$(
($VARIANTS | % {
    if ( $_['tag_as_latest'] ) {
@"
| ``:$( $_['tag'] )``, ``:latest`` | [View](variants/$( $_['tag'] )) |

"@
    }else {
@"
| ``:$( $_['tag'] )`` | [View](variants/$( $_['tag'] )) |

"@
    }
}) -join ''
)

"@

@"
## Usage

### QEMU builder

``````sh
# Note: The GID of the group 'kvm' in the container must match the host's. If not, use --privileged instead of --device. See: https://stackoverflow.com/questions/48422001/how-to-launch-qemu-kvm-from-inside-a-docker-container
docker run --rm -it \
    --device /dev/kvm \
    -v `$(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:$( $VARIANTS | ? { $_['tag'] -match '\bqemu\b' } | Select-Object -First 1 | % { $_['tag'] } ) packer build template.json
``````

See examples:

- [Ubuntu 20.04 VM ``.qcow2`` image](docs/examples/ubuntu2004-qemu)

### Virtualbox builder

The host may need to have an exact matching virtualbox version, or at least the same virtualbox minor version, if not virtualbox may not be able to start VMs. To verify virtualbox can start VMs, run the following, ensuring there is no error message:

``````sh
docker run --rm -it \
    --device /dev/vboxdrv \
    theohbrothers/docker-packer:$( $VARIANTS | ? { $_['tag'] -match '\bvirtualbox\b' } | Select-Object -First 1 | % { $_['tag'] } ) vboxmanage --version
``````

If all is well, to build a VM image:

``````sh
docker run --rm -it \
    --device /dev/vboxdrv \
    -v `$(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:$( $VARIANTS | ? { $_['tag'] -match '\bvirtualbox\b' } | Select-Object -First 1 | % { $_['tag'] } ) packer build template.json
``````

See examples:

- [Ubuntu 20.04 VM ``.ova``](docs/examples/ubuntu2004-virtualbox)

### Other builder(s)

``````sh
docker run --rm -it \
    -v `$(pwd):/src \
    -w /src \
    theohbrothers/docker-packer:$( $VARIANTS | ? { $_['tag'] -notmatch '\bqemu|virtualbox\b' } | Select-Object -First 1 | % { $_['tag'] } ) sh -c 'packer --version && packer build template.json'
``````


"@

@'
## Development

Requires Windows `powershell` or [`pwsh`](https://github.com/PowerShell/PowerShell).

```powershell
# Install Generate-DockerImageVariants module: https://github.com/theohbrothers/Generate-DockerImageVariants
Install-Module -Name Generate-DockerImageVariants -Repository PSGallery -Scope CurrentUser -Force -Verbose

# Edit ./generate templates

# Generate the variants
Generate-DockerImageVariants .
```

'@
