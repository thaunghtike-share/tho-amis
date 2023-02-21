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

source "amazon-ebs" "nixtune-rocky-9-arm64-python311" {
  ami_name      = "${local.name_prefix}rocky-9-arm64-python311-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.rocky-9-arm64.id
  ssh_username  = "rocky"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-rocky-9-arm64-python311"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo dnf install curl gcc openssl-devel bzip2-devel libffi-devel zlib-devel tar wget make -y",
      "wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz",
      "tar xzf Python-3.11.0.tgz",
      "cd Python-3.11.0",
      "sudo ./configure --enable-optimizations",
      "sudo make -j 2",
      "nproc",
      "sudo make altinstall",
      "python3.11 --version"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "rocky-9-arm64-python311.json"
    strip_path = true
  }
}
