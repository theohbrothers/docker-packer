# ubuntu2004-qemu

This example builds an Ubuntu 20.04 VM image using the [virtualbox builder (.iso)](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso).

```sh
# 1. Build
docker run --rm -it \
    --device /dev/vboxdrv \
    -v $(pwd):/src \
    -w /src \
    -p 127.0.0.1:5901:5901 \
    theohbrothers/docker-packer:master-efee68d-1.7.7-sops-virtualbox-6.1.44-ubuntu-20.04 packer build template.json

# 2. During the build, to connect to the VM's console from the host via RDP at rdp://127.0.0.1:5901

# 3. Once built, get VM .ova
ls build/*.ova
```
