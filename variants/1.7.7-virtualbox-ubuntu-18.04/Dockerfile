FROM ubuntu:18.04
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

# Install runtime dependencie
RUN runDeps="wget libguestfs-tools isolinux squashfs-tools xorriso mkisofs" \
    && apt-get update \
    && apt-get install --no-install-recommends -y $runDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get install --no-install-recommends -y virtualbox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Not GPL, must accept terms. See: https://www.virtualbox.org/wiki/Licensing_FAQ
# RUN apt-get update \
# && apt-get install --no-install-recommends -y virtualbox-ext-pack \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*