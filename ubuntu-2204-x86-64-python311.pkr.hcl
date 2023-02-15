data "amazon-ami" "ubuntu-2204-x86-64" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    architecture        = "x86_64"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "nixtune-ubuntu-2204-x86-64-python311" {
  ami_name      = "${local.name_prefix}ubuntu-2204-x86-64-python311-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "t3a.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.ubuntu-2204-x86-64.id
  ssh_username  = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-ubuntu-2204-x86-64-python311"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo add-apt-repository ppa:deadsnakes/ppa",
      "sudo apt install media-types libpython3.11-stdlib python3.11 -y",
      "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1",
      "python3.11 -V",
      "python --version"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "ubuntu-2204-x86-64-python311.json"
    strip_path = true
  }
}
