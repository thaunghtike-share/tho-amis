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

source "amazon-ebs" "nixtune-debian-11-arm64-java8" {
  ami_name      = "${local.name_prefix}debian-11-arm64-java8-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.debian-11-arm64.id
  ssh_username  = "admin"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-debian-11-arm64-java8"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/lib/apt/lists/* && sudo apt-get clean && sudo apt-get update -y && sudo apt-get upgrade -y",
      "sudo apt-get install software-properties-common -y",
      "sudo apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main'",
      "sudo rm -rf /var/lib/apt/lists/* && sudo apt-get clean && sudo apt-get update -y && sudo apt-get upgrade -y",
      "sudo apt install openjdk-8-jdk openjdk-8-jre -y",
      "java --version"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "debian-11-arm64-java8.json"
    strip_path = true
  }
}
