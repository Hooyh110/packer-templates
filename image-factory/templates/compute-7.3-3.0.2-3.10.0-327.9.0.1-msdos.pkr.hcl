locals {
  os_type       = "CentOS"
  node_type     = "compute"
  user_name     = "root"
  user_password = "Kingsoft123"
  iso_checksum  = "file:http://luna.galaxy.ksyun.com/images/baremetal/base/md5sum.txt"
  iso_url       = "http://luna.galaxy.ksyun.com/images/baremetal/base/CentOS-7.3-base-latest.qcow2"
  os_version    = 7.3
  timestamp     = formatdate("YYYYMMDDhhmmss", timestamp())
  image_id      = try(var.git_commit_id, local.timestamp)
  img_name      = "${local.os_type}-${local.os_version}-3.10.0-327.8.0.0-${local.node_type}-${local.image_id}.qcow2"
}

source "qemu" "image" {
  accelerator            = "kvm"
  boot_wait              = "1s"
  cpus                   = 8
  disk_size              = "56G"
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
  vnc_port_max           = "5975"
  vnc_port_min           = "5974"
  qemu_img_args {
    resize = ["--shrink"]
  }
}

build {
  name    = "compute"
  sources = ["source.qemu.image"]

  provisioner "file" {
    destination = "/etc/yum.repos.d/galaxy.repo"
    source      = "http/galaxy.repo"
  }
  provisioner "ansible" {
    inventory_directory = "inventory/"
    playbook_file       = "playbooks/compute.yml"
    extra_arguments = [
      "-e compute_module=6240_e2",
      "-vvv"
    ]
  }

  provisioner "shell" {
    scripts = [
      "scripts/install.d/90-raid-drive-megaraid_sas.bash",
      "scripts/install.d/90-raid-drive-mpt3sas.bash",
      "scripts/install.d/90-network-drive-i40e.bash",
      #"scripts/install.d/90-network-drive-mlnx.bash",
      
    ]
    expect_disconnect = true
  }

  provisioner "shell" {
    scripts = [
      "scripts/post-install.d/100-cleanup.bash"
    ]
    expect_disconnect = true
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
