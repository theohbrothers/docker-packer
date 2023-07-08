# ubuntu2004-qemu

This example builds an Ubuntu 20.04 VM image using the [QEMU builder](https://developer.hashicorp.com/packer/plugins/builders/qemu).

```sh
# 1. Build
docker run --rm -it \
    --privileged \
    -v $(pwd):/src \
    -w /src \
    -p 127.0.0.1:5901:5901 \
    -e PACKER_LOG=1 \
    theohbrothers/docker-packer:1.7.7-sops-qemu-ubuntu-20.04 packer build template.json

# 2. During the build, to connect to the VM's console from the host via VNC at vnc://127.0.0.1:5901
vncviewer -Shared 127.0.0.1:5901

# 3. Once built, get VM image info
docker run --rm -it -v $(pwd):/src -w /src theohbrothers/docker-packer:1.7.7-sops-qemu-ubuntu-20.04 qemu-img info build/*.qcow2
```
