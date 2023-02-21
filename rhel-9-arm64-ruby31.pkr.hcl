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
      "sudo yum install wget yum-utils make gcc openssl-devel bzip2-devel libffi-devel zlib-devel -y",
      "wget https://www.python.org/ftp/python/3.10.8/Python-3.10.8.tgz",
      "tar xzf Python-3.10.8.tgz",
      "cd Python-3.10.8",
      "sudo ./configure --enable-optimizations",
      "sudo make -j 2",
      "nproc",
      "sudo make altinstall",
      "python3.10 --version"
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
