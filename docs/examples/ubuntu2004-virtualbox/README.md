# ubuntu2004-qemu

This example builds an Ubuntu 20.04 VM image using the [virtualbox builder (.iso)](https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso).

```sh
# 1. Build
docker run --rm -it \
    --device /dev/vboxdrv \
    -v $(pwd):/src \
    -w /src \
    -p 127.0.0.1:5901:5901 \
    -e PACKER_LOG=1 \
    theohbrothers/docker-packer:1.7.7-sops-virtualbox-6.1.44-ubuntu-20.04 packer build template.json

# 2. During the build, to connect to the VM's console from the host via RDP at rdp://127.0.0.1:5901
# Note that VRDE (i.e. RDP server) will be available only if virtualbox guest additions is installed alongside virtualbox
# To check whether VRDE is enabled on the VM, run:
docker exec -it <container> vboxmanage showvminfo ubuntu2004-virtualbox

# 3. Once built, get VM .ova
ls build/*.ova
```
