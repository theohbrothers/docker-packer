@"
FROM $( $VARIANT['_metadata']['distro'] ):$( $VARIANT['_metadata']['distro_version'] )
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on `$BUILDPLATFORM, building for `$TARGETPLATFORM"

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


"@

Generate-DownloadBinary @{
    binary = 'packer'
    version = $VARIANT['_metadata']['package_version']
    checksumsUrl = "https://releases.hashicorp.com/packer/$( $VARIANT['_metadata']['package_version'] )/packer_$( $VARIANT['_metadata']['package_version'] )_SHA256SUMS"
    archiveformat = '.zip'
    # platforms = $VARIANT['_metadata']['platforms']
    destination = '/usr/local/bin/packer'
    testCommand = 'CHECKPOINT_DISABLE=1 packer version'
}

@"
# Disable packer checkpoints. See: https://www.packer.io/docs/configure#full-list-of-environment-variables-usable-for-packer
ENV CHECKPOINT_DISABLE=1


"@

if ([version]$VARIANT['_metadata']['package_version'] -ge [version]'1.8') {
@"
# Since packer >= 1.8, plugins must installed separately
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
    packer plugins install github.com/hashicorp/qemu v1.1.2; \
    packer plugins installed | grep qemu;


"@
    }
}

if ( $VARIANT['_metadata']['components'] -contains 'sops' ) {
    $SOPS_VERSION = "3.13.3"
    Generate-DownloadBinary @{
        binary = 'sops'
        version = $SOPS_VERSION
        checksumsUrl = "https://github.com/getsops/sops/releases/download/v$SOPS_VERSION/sops-v$SOPS_VERSION.checksums.txt"
        platformFallback = 'linux/amd64'
        destination = '/usr/local/bin/sops'
        testCommand = 'sops --version --disable-version-check'
    }

@"
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
    wget -qO- https://github.com/minio/mc/releases/download/RELEASE.2021-10-07T04-19-58Z/mc.linux-amd64.RELEASE.2021-10-07T04-19-58Z > /usr/local/bin/mc; \
    chmod +x /usr/local/bin/mc; \
    sha256sum /usr/local/bin/mc | grep '^aa58e16c74c38bc05ecf73bedee476eafb3a1c42ea1ac95635853b530a36be93 '; \
    mc --version

"@
