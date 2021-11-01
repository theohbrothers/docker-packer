@"
FROM $( $VARIANT['_metadata']['distro'] ):$( $VARIANT['_metadata']['distro_version'] )
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on `$BUILDPLATFORM, building for `$TARGETPLATFORM"

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

# Install basic tools
RUN apt-get update \
    && apt-get install --no-install-recommends -y sudo ca-certificates wget curl git rsync \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install tools for .vhd, .vmdk
# Fix apt dialog: https://github.com/moby/moby/issues/27988#issuecomment-462809153
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install --no-install-recommends -y libguestfs-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install tools for .iso
RUN apt-get update \
    && apt-get install --no-install-recommends -y sudo isolinux squashfs-tools xorriso mkisofs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install tools for storage
# mc: https://min.io/download#/linux
RUN wget -qO- https://dl.min.io/client/mc/release/linux-amd64/mc > /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc \
    && sha256sum /usr/local/bin/mc | grep aa58e16c74c38bc05ecf73bedee476eafb3a1c42ea1ac95635853b530a36be93


"@

$VARIANT['_metadata']['components'] | % {
    $component = $_

    switch( $component ) {

        'sops' {
            if ( $VARIANT['_metadata']['distro'] -eq 'alpine' -and $VARIANT['_metadata']['distro_version'] -eq '3.6' ) {
                @"
# Fix wget not working in alpine:3.6. https://github.com/gliderlabs/docker-alpine/issues/423
RUN apk add --no-cache libressl


"@
            }
            @"
RUN wget -qO- https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux > /usr/local/bin/sops && chmod +x /usr/local/bin/sops

RUN apt-get update \
    && apt-get install --no-install-recommends -y gnupg2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


"@
        }

        'virtualbox' {
                @"
RUN apt-get update \
    && apt-get install --no-install-recommends -y virtualbox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Not GPL, must accept terms. See: https://www.virtualbox.org/wiki/Licensing_FAQ
# RUN apt-get update \
# && apt-get install --no-install-recommends -y virtualbox-ext-pack \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*


"@
        }

        default {
            throw "No such component: $component"
        }
    }
}
