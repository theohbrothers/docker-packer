FROM ubuntu:20.04
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

# Disable packer checkpoints. See: https://www.packer.io/docs/configure#full-list-of-environment-variables-usable-for-packer
ENV CHECKPOINT_DISABLE=1

# Install apt dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y apt-transport-https ca-certificates gnupg2; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install packer
RUN set -eux; \
    buildDeps="curl gnupg2 software-properties-common"; \
    apt-get update; \
    apt-get install --no-install-recommends -y $buildDeps; \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -; \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"; \
    apt-get update; \
    apt-get install --no-install-recommends -y packer=1.7.7; \
    packer version; \
    apt-get purge --auto-remove -y $buildDeps; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install sops
RUN set -eux; \
    buildDeps="wget"; \
    apt-get update; \
    apt-get install --no-install-recommends -y $buildDeps; \
    wget -qO- https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux > /usr/local/bin/sops; \
    chmod +x /usr/local/bin/sops; \
    sha256sum /usr/local/bin/sops | grep '^185348fd77fc160d5bdf3cd20ecbc796163504fd3df196d7cb29000773657b74 '; \
    sops --version; \
    apt-get purge --auto-remove -y $buildDeps; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install gnupg for sops
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y gnupg2; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install basic tools
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y sudo ca-certificates wget curl git rsync; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install tools for .vhd, .vmdk
# Fix apt dialog: https://github.com/moby/moby/issues/27988#issuecomment-462809153
# Fix guestmount error 'supermin: failed to find a suitable kernel (host_cpu=x86_64)': https://github.com/steigr/docker-hipchat-server/issues/1
RUN set -eux; \
    apt-get update; \
    \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections; \
    apt-get install --no-install-recommends -y libguestfs-tools; \
    \
    apt-get install --no-install-recommends -y linux-image-generic; \
    \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install tools for .iso
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y sudo isolinux squashfs-tools xorriso mkisofs; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install tools for storage
# s3fs: https://github.com/s3fs-fuse/s3fs-fuse
# mc: https://min.io/download#/linux
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y s3fs; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    \
    wget -qO- https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2021-10-07T04-19-58Z > /usr/local/bin/mc; \
    chmod +x /usr/local/bin/mc; \
    sha256sum /usr/local/bin/mc | grep '^aa58e16c74c38bc05ecf73bedee476eafb3a1c42ea1ac95635853b530a36be93 '
