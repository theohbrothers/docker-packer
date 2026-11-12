FROM ubuntu:22.04
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

RUN set -eux; \
    apt-get update; \
    apt-get install -y ca-certificates gnupg2; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install provision tools
RUN set -eux; \
    apt-get update; \
    apt-get install -y wget unzip; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install packer
RUN set -eux; \
    PACKER_VERSION=1.11.2; \
    case "$( uname -m )" in \
        'x86') \
            URL="https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_386.zip"; \
            SHA256=fe5781307673843309be41ceac6541d4322640653f6b6e6eabd85375f9d70726; \
            ;; \
        'x86_64') \
            URL="https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip"; \
            SHA256=ced13efc257d0255932d14b8ae8f38863265133739a007c430cae106afcfc45a; \
            ;; \
        'armhf') \
            URL="https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_arm.zip"; \
            SHA256=2f6e1928204b61f171b9d79cbc697a5b35c65cd435e1a38bb648bb7e96dba284; \
            ;; \
        'armv7l') \
            URL="https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_arm.zip"; \
            SHA256=2f6e1928204b61f171b9d79cbc697a5b35c65cd435e1a38bb648bb7e96dba284; \
            ;; \
        'aarch64') \
            URL="https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_arm64.zip"; \
            SHA256=dd296d743dd4593304307583cff5290bba9b868fc2b0b605b64566f8141ca728; \
            ;; \
        'ppc64le') \
            URL="https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_ppc64le.zip"; \
            SHA256=ce00800a2b16bd964734b52714fe93d68889bb29acfddbe2f0fb68b2efe8b2b2; \
            ;; \
        *) \
            echo "Architecture not supported"; \
            exit 1; \
            ;; \
    esac; \
    FILE=packer.zip; \
    wget -q "$URL" -O "$FILE"; \
    echo "$SHA256  $FILE" | sha256sum -c -; \
    unzip "$FILE" -d extract; \
    mkdir -pv /usr/local/bin; \
    BIN=$( find extract -type f -name "packer" | head -n1 ); \
    mv -v "$BIN" /usr/local/bin/packer; \
    chmod +x /usr/local/bin/packer; \
    CHECKPOINT_DISABLE=1 packer version; \
    rm -rf extract; \
    rm -f "$FILE"; \
    :

# Disable packer checkpoints. See: https://www.packer.io/docs/configure#full-list-of-environment-variables-usable-for-packer
ENV CHECKPOINT_DISABLE=1

# Since packer >= 1.8, plugins must installed separately
# Define the packer plugin directory common to all users
ENV PACKER_PLUGIN_PATH=/usr/share/packer/plugins

RUN set -eux; \
    packer plugins install github.com/hashicorp/virtualbox v1.1.2; \
    packer plugins installed | grep virtualbox;

# Install sops
RUN set -eux; \
    SOPS_VERSION=3.13.3; \
    case "$( uname -m )" in \
        'x86_64') \
            URL="https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.amd64"; \
            SHA256=e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b; \
            ;; \
        'aarch64') \
            URL="https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.arm64"; \
            SHA256=53b0abacd38ef1b12a66d6c100956691b9cefce018d91f81e73ddf7438b94d77; \
            ;; \
        *) \
            URL="https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.amd64"; \
            SHA256=e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b; \
            ;; \
    esac; \
    FILE=sops; \
    wget -q "$URL" -O "$FILE"; \
    echo "$SHA256  $FILE" | sha256sum -c -; \
    BIN=sops; \
    mkdir -pv /usr/local/bin; \
    mv -v "$BIN" /usr/local/bin/sops; \
    chmod +x /usr/local/bin/sops; \
    sops --version --disable-version-check; \
    :

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
    curl -sSLO "https://download.virtualbox.org/virtualbox/7.1.2/SHA256SUMS"; \
    FILE="$( cat SHA256SUMS | grep 'Ubuntu~jammy_amd64.deb' | awk '{print $2}' | cut -d '*' -f2 )"; \
    PACKAGE="https://download.virtualbox.org/virtualbox/7.1.2/$FILE"; \
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
    wget -qO- https://github.com/minio/mc/releases/download/RELEASE.2021-10-07T04-19-58Z/mc.linux-amd64.RELEASE.2021-10-07T04-19-58Z > /usr/local/bin/mc; \
    chmod +x /usr/local/bin/mc; \
    sha256sum /usr/local/bin/mc | grep '^aa58e16c74c38bc05ecf73bedee476eafb3a1c42ea1ac95635853b530a36be93 '; \
    mc --version
