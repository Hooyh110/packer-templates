locals {
  os_type       = "CentOS"
  node_type     = "base"
  user_name     = "root"
  user_password = "Kingsoft123"
  anwserfile    = "anwserfiles/ks_centos_6.cfg"
  iso_checksum  = "c528d4bbac463589926fd1744ef115c4"
  iso_url       = "http://luna.galaxy.ksyun.com/images/baremetal-images/CentOS-6.5-sdn-dpdk-3.10.0-123.6.1.el6.ksyun.x86_64.qcow2"
  os_version    = 6.5
  timestamp     = regex_replace(timestamp(), "[- TZ:]", "")
  image_id      = try(var.git_commit_id, local.timestamp)
  img_name      = "${local.os_type}-${local.os_version}-${local.node_type}-${local.image_id}.qcow2"
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
  name    = "base"
  sources = ["source.qemu.image"]

  provisioner "file" {
    destination = "/etc/yum.repos.d/galaxy.repo"
    source      = "http/galaxy.repo"
  }

  provisioner "file" {
    destination = "/etc/"
    source      = "http/pip.conf"
  }

//   provisioner "shell" {
//     scripts = [
//       "scripts/pre-install.d/00-repo.bash",
//       "scripts/pre-install.d/10-centos6-cloud-init.bash",
//     ]
//     expect_disconnect = true
//   }

//   provisioner "file" {
//     destination = "/etc/cloud/cloud.cfg"
//     source      = "http/cloud.cfg"
//   }

//   provisioner "shell" {
//     scripts = [
//       "scripts/install.d/10-ssh-config.bash",
//       "scripts/install.d/20-base-packages.bash",
//       "scripts/install.d/90-raid-drive-megaraid_sas.bash",
//       "scripts/install.d/90-raid-drive-mpt3sas.bash",
//     ]
//     expect_disconnect = true
//   }


//   provisioner "shell" {
//     scripts = [
//       "scripts/post-install.d/100-cleanup.bash"
//     ]
//     expect_disconnect = true
//   }

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
