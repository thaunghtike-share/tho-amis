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

source "amazon-ebs" "nixtune-rocky-9-arm64-redis6" {
  ami_name      = "${local.name_prefix}rocky-9-arm64-redis6-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.rocky-9-arm64.id
  ssh_username  = "rocky"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-rocky-9-arm64-redis6"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf module list redis",
      "sudo dnf -y module reset redis",
      "sudo dnf install @redis:6",
      "sudo systemctl enable --now redis"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "rocky-9-arm64-redis6.json"
    strip_path = true
  }
}
