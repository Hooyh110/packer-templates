variable "mirror" {
  type    = string
  default = "http://centos.osuosl.org"
}
variable "mirror_url" {
  type    = string
  default = "http://10.178.88.1"
}
variable "osuadmin_passwd" {
  type      = string
  sensitive = true
  default   = "$6$S3y2eCRW3c6SjK/l$ym9rE8J7IZvzkJ5SRMYkxp2PrZ98FNkGy/leHLZU0ATm/yQqCA3l74VNLGdMWKPnhJL4JiB7jBDxj5k3.aZlj1"
}

source "qemu" "centos-stream-8" {
  accelerator      = "kvm"
  boot_command     = [
    "c<wait>",
    "linux /images/pxeboot/vmlinuz text biosdevname=0 net.ifnames=0 ",
    "inst.stage2=hd:LABEL=CentOS\\-Stream\\-8\\-BaseOS\\-aarch64 ",
    "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-stream-8/ks-aarch64.cfg<enter>",
    "initrd /images/pxeboot/initrd.img<enter>",
    "boot<enter><wait>"]
  boot_wait        = "10s"
  disk_interface   = "virtio-scsi"
  disk_size        = "80G"
  format           = "qcow2"
  headless         = true
  http_directory   = "http"
  iso_checksum     = "file:${var.mirror_url}/images/iso/sha1sum.txt"
  iso_url          = "${var.mirror_url}/images/iso/CentOS-Stream-8-aarch64-latest-dvd1.iso"
  qemu_binary      = "/usr/libexec/qemu-kvm"
  qemuargs         = [
    [
      "-m",
      "2048M"
    ],
    [
      "-machine",
      "gic-version=max,accel=kvm"
    ],
    [
      "-cpu",
      "host"
    ],
    [
      "-boot",
      "strict=on"
    ],
    [
      "-bios",
      "/usr/share/AAVMF/AAVMF_CODE.fd"
    ],
    [
      "-monitor",
      "none"
    ]
  ]
  shutdown_command = "/sbin/halt -h -p"
  ssh_password     = "Kingsoft123"
  ssh_port         = 22
  ssh_username     = "root"
  ssh_wait_timeout = "10000s"
  vnc_bind_address = "0.0.0.0"
  vnc_port_min     = 5980
  vnc_port_max     = 5999
  vm_name          = "centos-stream-8"
}

build {
  sources = [
    "source.qemu.centos-stream-8"
  ]

//  provisioner "shell-local" {
//    scripts = [
//      "scripts/common/berks-vendor.sh"
//    ]
//  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = [
      "scripts/common/install-cinc.sh"
    ]
  }
  provisioner "shell" {
    scripts = [
      "scripts/common/10-ssh-config.sh",
      "scripts/common/20-base-packages.sh",
    ]
    expect_disconnect = true
  }
//  provisioner "file" {
//    source = "cookbooks"
//    destination = "/tmp/cinc/"
//  }
//
//  provisioner "file" {
//    source = "inspec"
//    destination = "/tmp/cinc/"
//  }
//
//  provisioner "file" {
//    source = "chef/client.rb"
//    destination = "/tmp/cinc/client.rb"
//  }
//
//  provisioner "file" {
//    source = "chef/runlist/openstack.json"
//    destination = "/tmp/cinc/dna.json"
//  }
  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "http/cloud.cfg"
  }
  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    environment_vars = [
      "OSUADMIN_PASSWD=${var.osuadmin_passwd}"
    ]
    scripts         = [
      "scripts/common/converge-cinc.sh",
      "scripts/common/remove-cinc.sh",
      "scripts/common/minimize.sh"
    ]
  }
}
