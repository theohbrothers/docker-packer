FROM ubuntu:20.04
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

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

# Install runtime dependencies. Prevent apt dialog: https://github.com/moby/moby/issues/27988#issuecomment-462809153
RUN runDeps="wget libguestfs-tools isolinux squashfs-tools xorriso mkisofs" \
    && apt-get update \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get install --no-install-recommends -y $runDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

