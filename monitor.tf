resource "vsphere_virtual_machine" "monitor" {
  count            = 1
  name             = "monitor-${count.index+1}"
	resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
	datastore_id     = "${data.vsphere_datastore.datastore.id}"

	num_cpus = 2
	memory   = 4096
	guest_id = "${data.vsphere_virtual_machine.centos_template.guest_id}"

	scsi_type = "${data.vsphere_virtual_machine.centos_template.scsi_type}"

	network_interface {
		network_id   = "${data.vsphere_network.network.id}"
		adapter_type = "${data.vsphere_virtual_machine.centos_template.network_interface_types[0]}"
	}

	disk {
		label            = "disk0"
		size             = "${data.vsphere_virtual_machine.centos_template.disks.0.size}"
		eagerly_scrub    = "${data.vsphere_virtual_machine.centos_template.disks.0.eagerly_scrub}"
		thin_provisioned = "${data.vsphere_virtual_machine.centos_template.disks.0.thin_provisioned}"
	}

	clone {
		template_uuid = "${data.vsphere_virtual_machine.centos_template.id}"

		customize {
			linux_options {
				host_name = "monitor-${count.index+1}"
				domain = "vsphere.internal"
			}

			network_interface {
				ipv4_address = "192.168.1.120"
				ipv4_netmask = 24
			}

			ipv4_gateway = "192.168.1.1"
		}
	}

	provisioner "file" {
		source      = "artifacts/${var.vm_tomcat_artifact}.tar.gz"
		destination = "/tmp/${var.vm_tomcat_artifact}.tar.gz"

		connection {
			type     = "ssh"
			user     = "root"
			password = "${var.vm_root_password}"
		}
	}

	provisioner "file" {
		source      = "artifacts/tomcat.service"
		destination = "/etc/systemd/system/tomcat.service"

		connection {
			type     = "ssh"
			user     = "root"
			password = "${var.vm_root_password}"
		}
	}

	provisioner "remote-exec" {
    inline = [
			"tar -xf /tmp/${var.vm_tomcat_artifact}.tar.gz -C /home/qa",
			"mv /home/qa/${var.vm_tomcat_artifact} /home/qa/apache-tomcat",
			"chown -R qa:qa /home/qa/apache-tomcat",
			"systemctl stop firewalld",
			"systemctl disable firewalld",
			"systemctl daemon-reload",
			"systemctl start tomcat"
    ]

		connection {
			type     = "ssh"
			user     = "root"
			password = "${var.vm_root_password}"
		}
  }

}
