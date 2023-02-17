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

source "amazon-ebs" "nixtune-ubuntu-2204-x86-64-dotnet6" {
  ami_name      = "${local.name_prefix}ubuntu-2204-x86-64-dotnet6-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "t3a.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.ubuntu-2204-x86-64.id
  ssh_username  = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-ubuntu-2204-x86-64-dotnet6"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",
      "sudo apt install apt-transport-https",
      "sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* && sudo apt-get update -y",
      "sudo apt install dotnet-sdk-6.0 dotnet-runtime-6.0 -y",
      "dotnet --version"
    ]
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "ubuntu-2204-x86-64-dotnet6.json"
    strip_path = true
  }
}