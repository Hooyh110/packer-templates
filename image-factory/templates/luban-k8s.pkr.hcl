locals {
  os_type       = "CentOS"
  node_type     = "k8s"
  user_name     = "root"
  user_password = "Kingsoft123"
  iso_checksum  = "file:/root/yanxuanyu/image-factory/base.md5sum.txt"
  iso_url       = "/root/yanxuanyu/image-factory/CentOS-7.3-k8s-20210906083117.qocw2"
  os_version    = 7.3
  timestamp     = regex_replace(timestamp(), "[- TZ:]", "")
  image_id      = try(var.git_commit_id, local.timestamp)
  img_name      = "${local.os_type}-${local.os_version}-${local.node_type}-${local.image_id}.qocw2"
}

source "qemu" "image" {
  accelerator            = "kvm"
  boot_wait              = "1s"
  cpus                   = 8
  disk_size              = "51200"
  display                = "none"
  format                 = "qcow2"
  headless               = true
  http_directory         = "http"
  http_port_max          = "9000"
  http_port_min          = "8080"
  iso_checksum           = "${local.iso_checksum}"
  iso_url                = "${local.iso_url}"
  memory                 = 8096
  net_device             = "virtio-net"
  output_directory       = "output/"
  qemu_binary            = "/usr/libexec/qemu-kvm"
  qemuargs               = [["-m", "8192"], ["-smp", "8"]]
  shutdown_command       = "shutdown -h now"
  ssh_username           = "${local.user_name}"
  ssh_password           = "${local.user_password}"
  ssh_read_write_timeout = "20m"
  ssh_timeout            = "20m"
  vm_name                = "${local.img_name}"
  disk_image             = true
  vnc_bind_address       = "0.0.0.0"
  vnc_port_max           = "5980"
  vnc_port_min           = "5974"
  qemu_img_args  {
      resize = ["--shrink"]
  }
}

build {
  name    = "k8s"
  sources = ["source.qemu.image"]


  provisioner "shell" {
    inline = [
      "yum install kernel-4.14.49 kernel-devel-4.14.49 -y",
      "grub2-set-default 0"
    ]
  }

  post-processor "checksum" {
    checksum_types = ["md5"]
    output         = "${local.node_type}.{{.ChecksumType}}sum.txt"
  }

  post-processor "manifest" {
    strip_path = true
  }

  post-processor "shell-local" {
    inline = ["cat packer-manifest.json"]
  }
}
