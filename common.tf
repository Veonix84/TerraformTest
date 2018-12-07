provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"
  allow_unverified_ssl = true
}


data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
	name          = "VM Network"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "centos_template" {
	name = "Centos7Template"
	datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


variable "vm_root_password" {
  type = "string"
  default = "tester"
}

variable "vm_username" {
  type = "string"
  default = "qa"
}

variable "vm_password" {
  type = "string"
  default = "tester"
}

variable "vm_tomcat_artifact" {
  type = "string"
  default = "apache-tomcat-8.5.34"
}
