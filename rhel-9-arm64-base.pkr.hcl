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

source "amazon-ebs" "nixtune-rhel-9-arm64" {
  ami_name      = "${local.name_prefix}rhel-9-arm64-base-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "t3a.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.rhel-9-arm64.id
  ssh_username  = "ec2-user"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-rhel-9-arm64"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    script = "./cleanup.sh"
  }

  post-processor "manifest" {
    output     = "rhel-9-arm64-base.json"
    strip_path = true
  }
}
