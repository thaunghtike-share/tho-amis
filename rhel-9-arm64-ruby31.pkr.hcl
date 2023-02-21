data "amazon-ami" "rhel-9-arm64" {
  filters = {
    virtualization-type = "hvm"
    name                = "RHEL-9.1.0_HVM-20221101-arm64-2-Hourly2-GP2"
    root-device-type    = "ebs"
    architecture        = "arm64"
  }
  owners      = ["309956199498"]
  most_recent = true
}

source "amazon-ebs" "nixtune-rhel-9-arm64-ruby31" {
  ami_name      = "${local.name_prefix}rhel-9-arm64-ruby31-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.rhel-9-arm64.id
  ssh_username  = "ec2-user"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-rhel-9-arm64-ruby31"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo yum install gcc make git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel -y",
      "gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB",
      "curl -sSL https://get.rvm.io | bash -s stable",
      "/bin/bash -c '. /home/admin/.rvm/scripts/rvm && rvm install ruby-3.1.2 && ruby --version'"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "rhel-9-arm64-ruby31.json"
    strip_path = true
  }
}
