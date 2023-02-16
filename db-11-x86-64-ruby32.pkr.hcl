data "amazon-ami" "debian-11-x86-64" {
  filters = {
    virtualization-type = "hvm"
    name                = "debian-11-amd64-*"
    root-device-type    = "ebs"
    architecture        = "x86_64"
  }
  owners      = ["136693071363"]
  most_recent = true
}

source "amazon-ebs" "nixtune-debian-11-x86-64-ruby32" {
  ami_name      = "${local.name_prefix}debian-11-x86-64-ruby32-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "t3a.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.debian-11-x86-64.id
  ssh_username  = "admin"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-debian-11-x86-64-ruby32"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt clean && sudo rm -rf /var/lib/apt/lists/* && sudo apt update -y",
      "sudo apt install apt-transport-https ca-certificates gnupg2 curl -y",
      "gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB",
      "curl -sSL https://get.rvm.io | bash -s stable",
      "/bin/bash -c '. /usr/local/rvm/scripts/rvm && rvm install ruby-3.2.1'"    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "debian-11-x86-64-ruby32.json"
    strip_path = true
  }
}
