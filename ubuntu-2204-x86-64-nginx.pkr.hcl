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

source "amazon-ebs" "nixtune-ubuntu-2204-x86-64-nginx" {
  ami_name      = "${local.name_prefix}ubuntu-2204-x86-64-nginx-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "t3a.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.ubuntu-2204-x86-64.id
  ssh_username  = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-ubuntu-2204-x86-64-nginx"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo rm -rf /home/ec2-user/.ssh/authorized_keys",
      "sudo rm -rf /home/admin/.ssh/authorized_keys",
      "sudo rm -rf /home/ubuntu/.ssh/authorized_keys",
      "sudo rm -rf /root/.ssh/authorized_keys"
    ]
  }

  post-processor "manifest" {
    output     = "ubuntu-2204-x86-64-nginx.json"
    strip_path = true
  }
}
