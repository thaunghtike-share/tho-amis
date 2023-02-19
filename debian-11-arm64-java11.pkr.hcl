
data "amazon-ami" "debian-11-arm64" {
  filters = {
    virtualization-type = "hvm"
    name                = "debian-11-arm64-*"
    root-device-type    = "ebs"
    architecture        = "arm64"
  }
  owners      = ["136693071363"]
  most_recent = true
}

source "amazon-ebs" "nixtune-debian-11-arm64-java11" {
  ami_name      = "${local.name_prefix}debian-11-arm64-java11-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.debian-11-arm64.id
  ssh_username  = "admin"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-debian-11-arm64-java11"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/lib/apt/lists/* && sudo apt-get clean && sudo apt-get update -y && sudo apt-get upgrade -y",
      "sudo apt install default-jdk default-jre -y"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "debian-11-arm64-java11.json"
    strip_path = true
  }
}
