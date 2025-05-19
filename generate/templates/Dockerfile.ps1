@"
FROM $( $VARIANT['_metadata']['distro'] ):$( $VARIANT['_metadata']['distro_version'] )
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on `$BUILDPLATFORM, building for `$TARGETPLATFORM"

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
    apt-get install --no-install-recommends -y `$buildDeps; \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -; \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(
        if ($VARIANT['_metadata']['distro_version'] -eq '16.04' -or $VARIANT['_metadata']['distro_version'] -eq '18.04') {
            'focal'
        } else {
            '$(lsb_release -cs)'
        }) main"; \
    apt-get update; \
    apt-get install --no-install-recommends -y packer=$( $VARIANT['_metadata']['package_version'] ) || apt-get install --no-install-recommends -y packer='$( $VARIANT['_metadata']['package_version'] )-*'; \
    packer version; \
    apt-get purge --auto-remove -y `$buildDeps; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*


"@

if ([version]$VARIANT['_metadata']['package_version'] -ge [version]'1.8') {
@"
# Since packer 1.8, plugins must installed separately
# Define the packer plugin directory common to all users
ENV PACKER_PLUGIN_PATH=/usr/share/packer/plugins


"@

    if ( $VARIANT['_metadata']['components'] -match 'virtualbox-([^-]+)' ) {
@"
RUN set -eux; \
    packer plugins install github.com/hashicorp/virtualbox v1.1.2; \
    packer plugins installed | grep virtualbox;


"@
    }

    if ( $VARIANT['_metadata']['components'] -contains 'qemu' ) {
@"
RUN set -eux; \
    packer plugins install github.com/hashicorp/qemu v1.1.0; \
    packer plugins installed | grep qemu;


"@
    }
}

if ( $VARIANT['_metadata']['components'] -contains 'sops' ) {
        if ( $VARIANT['_metadata']['distro'] -eq 'alpine' -and $VARIANT['_metadata']['distro_version'] -eq '3.6' ) {
            @"
# Fix wget not working in alpine:3.6. https://github.com/gliderlabs/docker-alpine/issues/423
RUN apk add --no-cache libressl


"@
        }
        @"
# Install sops
RUN set -eux; \
    buildDeps="wget"; \
    apt-get update; \
    apt-get install --no-install-recommends -y `$buildDeps; \
    wget -qO- https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux > /usr/local/bin/sops; \
    chmod +x /usr/local/bin/sops; \
    sha256sum /usr/local/bin/sops | grep '^53aec65e45f62a769ff24b7e5384f0c82d62668dd96ed56685f649da114b4dbb '; \
    sops --version; \
    apt-get purge --auto-remove -y `$buildDeps; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install gnupg for sops
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y gnupg2; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*


"@
}

if ( $VARIANT['_metadata']['components'] -contains 'qemu' ) {
@"
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


"@
}

$VARIANT['_metadata']['components'] | % {
    if ($_ -match 'virtualbox-([^-]+)' ) {
        $version = $matches[1]
        $codename = & {
            if ($VARIANT['_metadata']['distro'] -eq 'ubuntu' -and $VARIANT['_metadata']['distro_version'] -eq '16.04') {
                'xenial'
            }elseif ($VARIANT['_metadata']['distro'] -eq 'ubuntu' -and $VARIANT['_metadata']['distro_version'] -eq '18.04') {
                'bionic'
            }elseif ($version -eq '6.1.26' -and $VARIANT['_metadata']['distro'] -eq 'ubuntu' -and $VARIANT['_metadata']['distro_version'] -eq '20.04') {
                'eoan'
            }elseif ($VARIANT['_metadata']['distro'] -eq 'ubuntu' -and $VARIANT['_metadata']['distro_version'] -eq '20.04') {
                'focal'
            }elseif ($VARIANT['_metadata']['distro'] -eq 'ubuntu' -and $VARIANT['_metadata']['distro_version'] -eq '22.04') {
                'jammy'
            }
        }
@"
# Virtualbox: https://www.virtualbox.org/wiki/Linux_Downloads
# Dynamically determine the package, using the SHA256SUMS file, because there is a 5 digit number suffix in the version that is unknown
# E.g. https://download.virtualbox.org/virtualbox/6.1.22/virtualbox-6.1_6.1.22-144080~Ubuntu~eoan_amd64.deb
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive \
    buildDeps="curl build-essential dkms"; \
    apt-get update; \
    apt-get install --no-install-recommends -y `$buildDeps; \
    curl -sSLO "https://download.virtualbox.org/virtualbox/$version/SHA256SUMS"; \
    FILE="`$( cat SHA256SUMS | grep 'Ubuntu~${codename}_amd64.deb' | awk '{print `$2}' | cut -d '*' -f2 )"; \
    PACKAGE="https://download.virtualbox.org/virtualbox/$version/`$FILE"; \
    curl -sSLO "`$PACKAGE"; \
    cat SHA256SUMS | grep "`$FILE" | sha256sum -c; \
    apt-get install --no-install-recommends -y "./`$FILE"; \
    vboxmanage --version; \
    rm -f "`$FILE"; \
    apt-get purge --auto-remove -y `$buildDeps; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Virtualbox extension pack: https://www.virtualbox.org/wiki/Downloads
# E.g. https://download.virtualbox.org/virtualbox/6.1.22/Oracle_VM_VirtualBox_Extension_Pack-6.1.22.vbox-extpack
# Not GPL, must accept terms. See: https://www.virtualbox.org/wiki/Licensing_FAQ
# RUN apt-get update \
# && apt-get install --no-install-recommends -y virtualbox-ext-pack \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*


"@
    }
}

@"
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

"@
