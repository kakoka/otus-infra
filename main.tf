# Destroy resources
# 
# for i in {0..8}; do echo "yes" | terraform destroy -target yandex_compute_instance.simple_instance[$i]; done && \
# for i in {0..3}; do echo "yes" | terraform destroy -target yandex_compute_instance.disk_instance[$i]; done && \
# for i in {0..3}; do echo "yes" | terraform destroy -target yandex_compute_disk.disk[$i]; done
#

#
# Instances without secondary disk
#

resource "yandex_compute_instance" "simple_instance" {
  count = "${length(var.hostnames_no_disk)}"
  description = "${lookup(var.hostnames_no_disk[count.index], "hostname")} compute node"
  name = "${lookup(var.hostnames_no_disk[count.index], "hostname")}"
  hostname = "${lookup(var.hostnames_no_disk[count.index], "hostname")}"
  platform_id = "standard-v1"
  count = "${length(var.hostnames_no_disk)}"

  resources {
    cores  = "${lookup(var.hostnames_no_disk[count.index], "cpu")}"
    memory = "${lookup(var.hostnames_no_disk[count.index], "mem")}"
    core_fraction = "${lookup(var.hostnames_no_disk[count.index], "frac")}"
  }

  boot_disk {
    initialize_params {
      name = "${lookup(var.hostnames_no_disk[count.index], "hostname")}-bootdisk"
      image_id = "fd8cn8os7a9dfgosb89r"
      size = 9
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.my-subnet.id}"
    nat       = false
  }

  metadata {
    user-data = "${file("bootstrap/metadata.yml")}"
  }

  labels {
    role = "${lookup(var.hostnames_no_disk[count.index], "tags")}"
  }
}

#
# Secondary disk
#

resource "yandex_compute_disk" "disk" {
     count = "${length(var.hostnames_with_disk)}"
     name  = "${lookup(var.hostnames_with_disk[count.index], "hostname")}-second-disk"
     type   = "network-hdd"
     size = "${lookup(var.hostnames_with_disk[count.index], "sdd")}"
}

#
#  Instances with secondary disk
#

resource "yandex_compute_instance" "disk_instance" {
  count = "${length(var.hostnames_with_disk)}"
  description = "${lookup(var.hostnames_with_disk[count.index], "hostname")} compute node with disk"
  name = "${lookup(var.hostnames_with_disk[count.index], "hostname")}"
  hostname = "${lookup(var.hostnames_with_disk[count.index], "hostname")}"
  platform_id = "standard-v1"
  count = "${length(var.hostnames_with_disk)}"

  # depends_on = "${element(yandex_compute_disk.*.id, count.index)}"

  resources {
    cores  = "${lookup(var.hostnames_with_disk[count.index], "cpu")}"
    memory = "${lookup(var.hostnames_with_disk[count.index], "mem")}"
    core_fraction = "${lookup(var.hostnames_with_disk[count.index], "frac")}"
  }

  boot_disk {
    initialize_params {
      name = "${lookup(var.hostnames_with_disk[count.index], "hostname")}-bootdisk"
      image_id = "fd8cn8os7a9dfgosb89r"
      size = 9
    }
  }
  secondary_disk {
    auto_delete = false
    disk_id = "${element(yandex_compute_disk.disk.*.id, count.index)}"
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.my-subnet.id}"
    nat       = false
  }

  metadata {
    user-data = "${file("bootstrap/metadata.yml")}"
  }

  labels {
    role = "${lookup(var.hostnames_with_disk[count.index], "tags")}"
  }
}

output "instance_name" {
  value = "yandex_compute_instance.disk_instance.name"
}

#
# Provision
#

resource "null_resource" "inventory_w" {
  count = "${length(var.hostnames_no_disk)}"

  triggers {
    count = "${length(var.hostnames_no_disk)}"
  }

  # provisioner "local-exec" {
  # command = "ansible-playbook -i '${element(yandex_compute_instance.simple_instance.*.network_interface.0.ip_address, count.index)},' provision/base.yml --ssh-common-args='-o StrictHostKeyChecking=no' --key-file '~/.ssh/otus-user'"
  # command = "ansible-playbook -i '${element(yandex_compute_instance.*.network_interface.0.ip_address, count.index)},' provision/base.yml --ssh-common-args='-o StrictHostKeyChecking=no' --key-file '~/.ssh/otus-user'"
  # }

  provisioner "local-exec" {
    command = "echo '[${lookup(var.hostnames_no_disk[count.index], "tags")}]\n${lookup(var.hostnames_no_disk[count.index], "hostname")}' >> provision/inventory.yml"
  }
}

resource "null_resource" "inventory_d" {
  count = "${length(var.hostnames_with_disk)}"

  triggers {
    count = "${length(var.hostnames_with_disk)}"
  }

  provisioner "local-exec" {
    command = "echo '[${lookup(var.hostnames_with_disk[count.index], "tags")}]\n${lookup(var.hostnames_with_disk[count.index], "hostname")}' >> provision/inventory.yml"
  }
}

# resource "null_resource" "etcd_ip" {
#   count = "${length(var.hostnames_with_disk)}"
#   provisioner "local-exec" {
#     command = "echo 'etcd_hostname: '${element(yandex_compute_instance.disk_instance.nfs.network_interface.0.ip_address, count.index)} >> provision/roles/etcd/deafults/main.yml"
#   }
# }

# resource "null_resource" "ansible2" {
#   count = "${length(var.hostnames_with_disk)}"

#   triggers {
#     count = "${length(var.hostnames_with_disk)}"
#   }

#   provisioner "local-exec" {
#     command = "ansible-playbook -i '${element(yandex_compute_instance.disk_instance.*.network_interface.0.ip_address, count.index)},' provision/base.yml --ssh-common-args='-o StrictHostKeyChecking=no' --key-file '~/.ssh/otus-user'"
#   }
#   provisioner "local-exec" {
#     command = "/usr/bin/echo [${lookup(var.hostnames_with_disk[count.index], "tags")}]\n${lookup(var.hostnames_with_disk[count.index], "hostname")} ${element(yandex_compute_instance.disk_instance.*.network_interface.0.ip_address, count.index)} >> provision/inventory.yml"
#   }
# }


# # yandex_compute_instance.db.*.network_interfaces.primary_v4_address.one_to_one_nat.address
#
# ${element(yandex_compute_instance.simple_instance.*.network_interface.0.ip_address, count.index)}
# ${element(yandex_compute_instance.disk_instance.*.network_interface.0.ip_address, count.index)}
#