locals {
  ssh_path = "/home/vboxuser/.ssh/id_rsa"
}

# Создание VPC и подсети
resource "yandex_vpc_network" "this" {
  name = "private"
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.this.id
}


resource "yandex_vpc_address" "addr" {
  name = "vm-adress"
  external_ipv4_address {
    zone_id = "ru-central1-a"
}
}


# Создание диска и виртуальной машины
resource "yandex_compute_disk" "boot_disk" {
  name     = "boot-disk"
  zone     = "ru-central1-a"
  image_id = "fd8ba9d5mfvlncknt2kd" # Ubuntu 22.04 LTS
  size     = 10
}

resource "yandex_compute_instance" "this" {
  name                      = "linux-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    memory = "4"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat            = true
    nat_ip_address = yandex_vpc_address.addr.external_ipv4_address[0].address
  }
  provisioner "local-exec" {
    command = "echo \"${self.network_interface.0.nat_ip_address} ansible_ssh_private_key_file=${local.ssh_path} ansible_user=admin \n \" > hosts2"
  }
  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_container_registry" "my-registry" {
  name       = "reg"
}

output "public_ip" {
 value = yandex_compute_instance.this.network_interface.0.nat_ip_address
}
