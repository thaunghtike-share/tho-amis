data "amazon-ami" "rocky-9-arm64" {
  filters = {
    virtualization-type = "hvm"
    name                = "Rocky-9-EC2-Base-*"
    root-device-type    = "ebs"
    architecture        = "arm64"
  }
  owners      = ["792107900819"]
  most_recent = true
}

source "amazon-ebs" "nixtune-rocky-9-arm64-ruby32" {
  ami_name      = "${local.name_prefix}rocky-9-arm64-ruby32-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.rocky-9-arm64.id
  ssh_username  = "rocky"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-rocky-9-arm64-ruby32"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo dnf install gcc make git-core zlib zlib-devel gcc-c++ patch readline readline-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel -y",
      "gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB",
      "curl -sSL https://get.rvm.io | bash -s stable",
      "/bin/bash -c '. ~/.rvm/scripts/rvm && rvm install ruby-3.2.1 -j 1 && ruby --version'"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "rocky-9-arm64-ruby32.json"
    strip_path = true
  }
}
