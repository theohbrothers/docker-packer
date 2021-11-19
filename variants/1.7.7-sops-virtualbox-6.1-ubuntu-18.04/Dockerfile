FROM ubuntu:18.04
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

# Disable packer checkpoints. See: https://www.packer.io/docs/configure#full-list-of-environment-variables-usable-for-packer
ENV CHECKPOINT_DISABLE=1

# Install packer
RUN buildDeps="gnupg2 curl software-properties-common" \
    && apt-get update \
    && apt-get install --no-install-recommends -y $buildDeps \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update \
    && apt-get install --no-install-recommends -y packer=1.7.7 \
    && apt-get purge --auto-remove -y $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install sops, gpg for sops
RUN buildDeps="wget" \
    && apt-get update \
    && apt-get install --no-install-recommends -y $buildDeps \
    && wget -qO- https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux > /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops \
    && sha256sum /usr/local/bin/sops | grep 185348fd77fc160d5bdf3cd20ecbc796163504fd3df196d7cb29000773657b74 \
    && apt-get purge --auto-remove -y $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install --no-install-recommends -y gnupg2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Virtualbox: https://www.virtualbox.org/wiki/Linux_Downloads
RUN buildDeps="gnupg2 wget software-properties-common" \
    && apt-get update \
    && apt-get install --no-install-recommends -y $buildDeps \
    && wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | apt-key add - \
    && wget -qO- https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" \
    && apt-get update \
    && apt-get install --no-install-recommends -y virtualbox-6.1 \
    && apt-get purge --auto-remove -y $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Virtualbox extension pack: https://www.virtualbox.org/wiki/Downloads
# Not GPL, must accept terms. See: https://www.virtualbox.org/wiki/Licensing_FAQ
# RUN apt-get update \
# && apt-get install --no-install-recommends -y virtualbox-ext-pack \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*

# Install basic tools
RUN apt-get update \
    && apt-get install --no-install-recommends -y sudo ca-certificates wget curl git rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install tools for .vhd, .vmdk
# Fix apt dialog: https://github.com/moby/moby/issues/27988#issuecomment-462809153
# Fix guestmount error 'supermin: failed to find a suitable kernel (host_cpu=x86_64)': https://github.com/steigr/docker-hipchat-server/issues/1
RUN apt-get update \
    \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get install --no-install-recommends -y libguestfs-tools \
    \
    && apt-get install --no-install-recommends -y linux-image-generic \
    \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install tools for .iso
RUN apt-get update \
    && apt-get install --no-install-recommends -y sudo isolinux squashfs-tools xorriso mkisofs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install tools for storage
# s3fs: https://github.com/s3fs-fuse/s3fs-fuse
# mc: https://min.io/download#/linux
RUN apt-get update \
    && apt-get install --no-install-recommends -y s3fs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    \
    && wget -qO- https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2021-10-07T04-19-58Z > /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc \
    && sha256sum /usr/local/bin/mc | grep aa58e16c74c38bc05ecf73bedee476eafb3a1c42ea1ac95635853b530a36be93
