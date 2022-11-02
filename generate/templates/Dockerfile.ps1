@"
FROM $( $VARIANT['_metadata']['distro'] ):$( $VARIANT['_metadata']['distro_version'] )
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on `$BUILDPLATFORM, building for `$TARGETPLATFORM"

# Disable packer checkpoints. See: https://www.packer.io/docs/configure#full-list-of-environment-variables-usable-for-packer
ENV CHECKPOINT_DISABLE=1

# Install packer
RUN buildDeps="gnupg2 curl software-properties-common" \
    && apt-get update \
    && apt-get install --no-install-recommends -y `$buildDeps \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com `$(lsb_release -cs) main" \
    && apt-get update \
    && apt-get install --no-install-recommends -y packer=$( $VARIANT['_metadata']['package_version'] ) \
    && apt-get purge --auto-remove -y `$buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


"@

$VARIANT['_metadata']['components'] | % {
    if ($_ -eq 'sops') {
        if ( $VARIANT['_metadata']['distro'] -eq 'alpine' -and $VARIANT['_metadata']['distro_version'] -eq '3.6' ) {
            @"
# Fix wget not working in alpine:3.6. https://github.com/gliderlabs/docker-alpine/issues/423
RUN apk add --no-cache libressl


"@
        }
        @"
# Install sops, gpg for sops
RUN buildDeps="wget" \
    && apt-get update \
    && apt-get install --no-install-recommends -y `$buildDeps \
    && wget -qO- https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux > /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops \
    && sha256sum /usr/local/bin/sops | grep 185348fd77fc160d5bdf3cd20ecbc796163504fd3df196d7cb29000773657b74 \
    && apt-get purge --auto-remove -y `$buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install --no-install-recommends -y gnupg2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


"@
    }

    if ($_ -match 'virtualbox-([^-]+)') {
        $version = $matches[1]
        $codename = & {
            if ($VARIANT['_metadata']['distro'] -eq 'ubuntu' -and $VARIANT['_metadata']['distro_version'] -eq '16.04') {
                'xenial'
            }elseif ($VARIANT['_metadata']['distro'] -eq 'ubuntu' -and $VARIANT['_metadata']['distro_version'] -eq '18.04') {
                'bionic'
            }else {
                'eoan'
            }
        }
        @"
# Virtualbox: https://www.virtualbox.org/wiki/Linux_Downloads
# Dynamically determine the package, using the SHA256SUMS file, because there is a 5 digit number suffix in the version that is unknown
# E.g. https://download.virtualbox.org/virtualbox/6.1.22/virtualbox-6.1_6.1.22-144080~Ubuntu~eoan_amd64.deb
RUN export DEBIAN_FRONTEND=noninteractive \
    buildDeps="curl build-essential dkms" \
    && apt-get update \
    && apt-get install --no-install-recommends -y `$buildDeps \
    && curl -sSLO "https://download.virtualbox.org/virtualbox/$version/SHA256SUMS" \
    && FILE="`$( cat SHA256SUMS | grep 'Ubuntu~${codename}_amd64.deb' | awk '{print `$2}' | cut -d '*' -f2 )" \
    && PACKAGE="https://download.virtualbox.org/virtualbox/$version/`$FILE" \
    && curl -sSLO "`$PACKAGE" \
    && cat SHA256SUMS | grep "`$FILE" | sha256sum -c \
    && apt-get install --no-install-recommends -y "./`$FILE" \
    && vboxmanage --version \
    && rm -f "`$FILE" \
    && apt-get purge --auto-remove -y `$buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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

"@
