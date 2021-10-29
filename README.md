# docker-webhook

[![github-actions](https://github.com/theohbrothers/docker-webhook/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/docker-webhook/actions)
[![github-release](https://img.shields.io/github/v/release/theohbrothers/docker-webhook?style=flat-square)](https://github.com/theohbrothers/docker-webhook/releases/)
[![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/docker-webhook/latest)](https://hub.docker.com/r/theohbrothers/docker-webhook)

Dockerized [`webhook`](https://github.com/adnanh/webhook) with useful tools.

## Tags

| Tag | Dockerfile Build Context |
|:-------:|:---------:|
| `:1.7.7-ubuntu-18.04`, `:latest` | [View](variants/1.7.7-ubuntu-18.04 ) |
| `:1.7.7-virtualbox-ubuntu-18.04` | [View](variants/1.7.7-virtualbox-ubuntu-18.04 ) |

## Usage

```sh
# Create hooks.yml, see: https://github.com/adnanh/webhook#configuration
cat - > hooks.yml <<'EOF'
- id: hello-world
  execute-command: echo
EOF

# Start container
docker run -it -p 9000:9000 -v $(pwd)/hooks.yml:/config/hooks.yml:ro theohbrothers/docker-webhook

# Run the webhook
wget -qO- "http://$HOSTNAME:9000/hooks/hello-world"
```

## FAQ

### Q: `webhook` fails with error `__nanosleep_time64: symbol not found`

On Raspberry Pi, running `alpine-3.12` fails with error:

```sh
$ docker run -it theohbrothers/docker-webhook:2.8.0-alpine-3.12
Error relocating /usr/local/bin/webhook: __nanosleep_time64: symbol not found
```

The solution is to use `alpine-3.13` or later

```sh
$ docker run -it theohbrothers/docker-webhook:2.8.0-alpine-3.13
```

### Q: `ping` fails with error `ping: clock_gettime(MONOTONIC) failed`

On Raspberry Pi, running `ping` on `alpine-3.13` and above might fail with error:

```sh
$ docker run -it theohbrothers/docker-webhook:2.8.0-alpine-3.13
PING 1.1.1.1 (1.1.1.1): 56 data bytes
ping: clock_gettime(MONOTONIC) failed
```

The solution is to use `--security-opt seccomp=unconfined` option. See [here](https://gitlab.alpinelinux.org/alpine/aports/-/issues/12091)

```sh
$ docker run -it --security-opt seccomp=unconfined theohbrothers/docker-webhook:2.8.0-alpine-3.13
```