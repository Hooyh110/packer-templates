packer-templates
================

Packer templates used to build base box images at the OSL for OpenStack and
Ganeti.

The target architectures are:

* x86_64
* ppc64
* ppc64le
* aarch64

To build an image for use on OpenStack, run `bin/build_image.sh` with the
relevant options. Make sure your `scripts` and kickstart configuration files
served by Packer's `http` server are available in the right place in this repo.

# run
```
# 将json文件进行转格式操作
packer fix compute-7.6-ks3-3.0.2-3.10.0-957.el7.aarch64.json > compute-7.6-ks3-3.0.2-3.10.0-957.el7.aarch64-openstack.json
# 执行构建
./bin/build_image.sh -t compute-7.6-ks3-3.0.2-3.10.0-957.el7.aarch64-openstack.json
```