data "amazon-ami" "ubuntu-2204-arm64" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/*ubuntu-jammy-22.04-arm64-server-*"
    root-device-type    = "ebs"
    architecture        = "arm64"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "nixtune-ubuntu-2204-arm64" {
  ami_name      = "${local.name_prefix}ubuntu-2204-arm64-base-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.ubuntu-2204-arm64.id
  ssh_username  = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-ubuntu-2204-arm64"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "ubuntu-2204-arm64-base.json"
    strip_path = true
  }
}
