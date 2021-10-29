@"
# docker-packer

[![github-actions](https://github.com/theohbrothers/docker-packer/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/docker-packer/actions)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/docker-packer?style=flat-square)](https://github.com/theohbrothers/docker-packer/releases/)
[![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/docker-packer/latest)](https://hub.docker.com/r/theohbrothers/docker-packer)

Dockerized [``webhook``](https://github.com/adnanh/webhook) with useful tools.

## Tags

| Tag | Dockerfile Build Context |
|:-------:|:---------:|
$(
($VARIANTS | % {
    if ( $_['tag_as_latest'] ) {
@"
| ``:$( $_['tag'] )``, ``:latest`` | [View](variants/$( $_['tag'] ) ) |

"@
    }else {
@"
| ``:$( $_['tag'] )`` | [View](variants/$( $_['tag'] ) ) |

"@
    }
}) -join ''
)

"@
