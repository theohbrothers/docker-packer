FROM ubuntu:16.04
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
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main"; \
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
    wget -qO- https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux > /usr/local/bin/sops; \
    chmod +x /usr/local/bin/sops; \
    sha256sum /usr/local/bin/sops | grep '^53aec65e45f62a769ff24b7e5384f0c82d62668dd96ed56685f649da114b4dbb '; \
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

# Virtualbox: https://www.virtualbox.org/wiki/Linux_Downloads
# Dynamically determine the package, using the SHA256SUMS file, because there is a 5 digit number suffix in the version that is unknown
# E.g. https://download.virtualbox.org/virtualbox/6.1.22/virtualbox-6.1_6.1.22-144080~Ubuntu~eoan_amd64.deb
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive \
    buildDeps="curl build-essential dkms"; \
    apt-get update; \
    apt-get install --no-install-recommends -y $buildDeps; \
    curl -sSLO "https://download.virtualbox.org/virtualbox/5.2.44/SHA256SUMS"; \
    FILE="$( cat SHA256SUMS | grep 'Ubuntu~xenial_amd64.deb' | awk '{print $2}' | cut -d '*' -f2 )"; \
    PACKAGE="https://download.virtualbox.org/virtualbox/5.2.44/$FILE"; \
    curl -sSLO "$PACKAGE"; \
    cat SHA256SUMS | grep "$FILE" | sha256sum -c; \
    apt-get install --no-install-recommends -y "./$FILE"; \
    vboxmanage --version; \
    rm -f "$FILE"; \
    apt-get purge --auto-remove -y $buildDeps; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Virtualbox extension pack: https://www.virtualbox.org/wiki/Downloads
# E.g. https://download.virtualbox.org/virtualbox/6.1.22/Oracle_VM_VirtualBox_Extension_Pack-6.1.22.vbox-extpack
# Not GPL, must accept terms. See: https://www.virtualbox.org/wiki/Licensing_FAQ
# RUN apt-get update \
# && apt-get install --no-install-recommends -y virtualbox-ext-pack \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*

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
