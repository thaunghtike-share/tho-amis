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

source "amazon-ebs" "nixtune-debian-11-x86-64-python311" {
  ami_name      = "${local.name_prefix}debian-11-x86-64-ruby31-{{isotime `2006-01-02`}}-{{timestamp}}"
  instance_type = "t3a.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.debian-11-x86-64.id
  ssh_username  = "admin"
}

build {
  sources = [
    "source.amazon-ebs.nixtune-debian-11-x86-64-python311"
  ]

  provisioner "shell" {
    script = "./setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/lib/apt/lists/* && sudo apt-get clean && sudo apt-get update -y && sudo apt-get upgrade -y",
      "sudo apt-get install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y",
      "wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz",
      "tar -xvf Python-3.11.0.tgz",
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
    output     = "debian-11-x86-64-python311.json"
    strip_path = true
  }
}
