locals {
  os_type       = "CentOS"
  node_type     = "base"
  user_name     = "root"
  user_password = "Kingsoft123"
  anwserfile    = "anwserfiles/ks_centos_7_aarch64.cfg"
  iso_checksum  = "file:http://luna.galaxy.ksyun.com/images/iso/sha1sum.txt"
  iso_url       = "http://luna.galaxy.ksyun.com/images/iso/CentOS-7-aarch64-Everything-1810.iso"

  #iso_checksum  = "file:http://10.91.128.61/images/baremetal/base/md5sum.txt"
  #iso_url       = "http://10.91.128.61/images/baremetal/base/CentOS-7.6-base-shangtang.qcow2"
  os_version    = 7.6
  timestamp     = formatdate("YYYYMMDDhhmmss", timestamp())
  image_id      = try(var.git_commit_id, local.timestamp)
  img_name      = "${local.os_type}-${local.os_version}-paas-3.0.2-4.14.0.el7-aarch64-latest.qcow2"
}

source "qemu" "base" {
  accelerator = "kvm"
    boot_command = [
      "<wait>",
      "c",
      "<esc><wait>",
      "c",
      "set default='0'",
      "set timeout=10",
      "<tab> text ",
      "ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.anwserfile}<enter>", // 输入 Linux 内核引导命令，并传递参数
      "boot<enter><wait>"
  ]
//  boot_command = [
//        "<wait>",                                      // 等待虚拟机启动
//        "c",                                           // 模拟按下 "c" 键
//        "<tab>   linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS\\x207\\x20aarch64 text biosdevname=0 net.ifnames=0 ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.anwserfile}<enter>", // 输入 Linux 内核引导命令，并传递参数
//        "<tab>    initrd /images/pxeboot/initrd.img<enter>",    // 指定 initrd 镜像路径
//        "<wait>",                                      // 等待虚拟机启动
//        "<enter>",                                     // 模拟按下 "Enter" 键
//        "<ctrl> x <enter>",                                 // 确认启动
//        "<wait>"                                      // 等待虚拟机启动完成
//
//  ]

  boot_wait              = "1s"
  cpus                   = 8
  disk_size              = "50G"
  display                = "none"
  format                 = "qcow2"
  headless               = true
  http_directory         = "http"
  http_port_max          = "9000"
  http_port_min          = "8080"
  iso_url                = "${local.iso_url}"
  iso_checksum           = "${local.iso_checksum}"

  memory                 = 8096
  net_device             = "virtio-net"
  output_directory       = "output/"
  qemu_binary            = "/usr/libexec/qemu-kvm"
  qemuargs               = [
    ["-m", "8192"],
    ["-smp", "8"],
    ["-machine", "gic-version=3,accel=kvm"],
    ["-cpu", "host"],
    [ "-boot", "strict=on" ],
    [ "-bios", "/usr/share/AAVMF/AAVMF_CODE.fd" ],
    [ "-monitor", "none" ]
  ]
  shutdown_command       = "shutdown -h now"
  ssh_username           = "${local.user_name}"
  ssh_password           = "${local.user_password}"
  ssh_read_write_timeout = "20m"
  ssh_timeout            = "20m"
  vm_name                = "${local.img_name}"
  vnc_bind_address       = "0.0.0.0"
  vnc_port_max           = "5975"
  vnc_port_min           = "5974"
}
build {
  name    = "base"
  sources = ["source.qemu.base"]

  provisioner "file" {
    destination = "/etc/yum.repos.d/galaxy.repo"
    source      = "http/galaxy_centos_arm.repo"
  }

  provisioner "file" {
    destination = "/etc/"
    source      = "http/pip.conf"
  }
//  provisioner "ansible" {
//    inventory_directory = "inventory/"
//    playbook_file       = "playbooks/compute.yml"
//    extra_arguments = [
//    "-e compute_module=paas_3.10.0_1062",
//      "-vvv"
//    ]
//  }

  provisioner "shell" {
    scripts = [
      "scripts/pre-install.d/00-repo.bash",
      "scripts/pre-install.d/10-cloud-init.bash",
    ]
    expect_disconnect = true
  }

  provisioner "file" {
    destination = "/etc/cloud/"
    sources = [
      "http/cloud.cfg",
      "http/ds-identify.cfg"
    ]
  }


//  provisioner "shell" {
//    scripts = [
//      "scripts/install.d/60-update-kernel.bash",
//      "scripts/install.d/10-ssh-config.bash",
//      "scripts/install.d/20-base-packages.bash",
//    ]
//    expect_disconnect = true
//    pause_before      = "10s"
//  }
//
//  provisioner "shell" {
//    scripts = [
//      "scripts/install.d/90-raid-drive-megaraid_sas_7.6-3.10.0-957.bash",
//      "scripts/install.d/90-raid-drive-mpt3sas.bash",
//      "scripts/install.d/90-network-drive-i40e-3.0.2-7.6.bash",
//      "scripts/install.d/90-network-drive-x722-3.0.2-7.6.bash",
//    ]
//    expect_disconnect = true
//  }

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

