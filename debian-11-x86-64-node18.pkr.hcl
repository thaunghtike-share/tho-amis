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

source "amazon-ebs" "nixtune-debian-11-x86-64-node18" {
  ami_name      = "${local.name_prefix}debian-11-x86-64-node18-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "t3a.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.debian-11-x86-64.id
  ssh_username  = "admin"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-debian-11-x86-64-node18"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/lib/apt/lists/* && sudo apt-get clean && sudo apt-get update -y && sudo apt-get upgrade -y",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install nodejs -y"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "debian-11-x86-64-node18.json"
    strip_path = true
  }
}
