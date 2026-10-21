variable "build_password" {
  type      = string
  sensitive = true
}

packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.1.5"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = ">= 1.1.7"
    }
  }
}

source "virtualbox-iso" "ubuntu2204" {
  vm_name       = "TF-UBUNTU2204-BUILD"
  guest_os_type = "Ubuntu_64"
  headless      = false

  iso_url      = "iso/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"

  output_directory = "output/virtualbox-ubuntu2204"
  format           = "ova"

  cpus = 1
  memory               = 4096
  disk_size            = 40960
  hard_drive_interface = "sata"

  http_directory = "http"
  boot_wait      = "10s"

  boot_command = [
    "<esc><wait>c<wait>",
    "linux /casper/vmlinuz autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  ssh_username = "techforward"
  ssh_password = var.build_password
  ssh_timeout = "30m"

  shutdown_command = "sudo passwd -l techforward && sudo shutdown -P now"
  shutdown_timeout = "10m"
}

build {
  name    = "techforward-ubuntu2204"
  sources = ["source.virtualbox-iso.ubuntu2204"]

  provisioner "shell" {
    script = "scripts/setup.sh"
  }

  post-processor "vagrant" {
    output = "output/techforward-ubuntu2204-candidate.box"
    vagrantfile_template = "box.Vagrantfile"
  }
}
