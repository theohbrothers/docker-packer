FROM ubuntu:18.04
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
    PACKER_VERSION=1.7.7; \
    case "$( uname -m )" in \
        'x86') \
            URL="https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_386.zip"; \
            SHA256=91ce6e6b6cef8515d7bc8718addb48799df7692a18dbbb1ad0f59e5c26c577b4; \
            ;; \
        'x86_64') \
            URL="https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_amd64.zip"; \
            SHA256=8513c3679d51141c39da3d95c691fcfc4b2ccc20e96ac5244b58b98899d6fe54; \
            ;; \
        'armhf') \
            URL="https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_arm.zip"; \
            SHA256=27aefc9f6235817163d31fec582b84dc676431049448a584b371b9307b822433; \
            ;; \
        'armv7l') \
            URL="https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_arm.zip"; \
            SHA256=27aefc9f6235817163d31fec582b84dc676431049448a584b371b9307b822433; \
            ;; \
        'aarch64') \
            URL="https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_arm64.zip"; \
            SHA256=c44d4f4c6776154a95a700c4b8caefb07c96652deb4ca6b265d19d767b31faeb; \
            ;; \
        'ppc64le') \
            URL="https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_ppc64le.zip"; \
            SHA256=69fc1c3d3f64878cf5460e6aa8bbcec696275c240068071a56cc326954635b8a; \
            ;; \
        's390x') \
            URL="https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_s390x.zip"; \
            SHA256=0acc1c9be32d55a678f1435948952376b682b204b33209ce26d5b9ba0bb75771; \
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

# Install kvm. See: https://help.ubuntu.com/community/KVM/Installation
RUN set -eux; \
    apt-get update; \
    \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections; \
    apt-get install -y --no-install-recommends qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils; \
    apt-get install -y ovmf; \
    \
    virt-host-validate || true; \
    qemu-system-x86_64 --version; \
    libvirtd --version; \
    virsh --version; \
    \
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
    wget -qO- https://github.com/minio/mc/releases/download/RELEASE.2021-10-07T04-19-58Z/mc.linux-amd64.RELEASE.2021-10-07T04-19-58Z > /usr/local/bin/mc; \
    chmod +x /usr/local/bin/mc; \
    sha256sum /usr/local/bin/mc | grep '^aa58e16c74c38bc05ecf73bedee476eafb3a1c42ea1ac95635853b530a36be93 '; \
    mc --version
