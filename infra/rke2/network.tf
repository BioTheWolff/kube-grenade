locals {
  network_cidr = "192.168.198.0/24"
}

data "openstack_networking_network_v2" "public" {
  name = "public"
}

data "openstack_networking_secgroup_v2" "rancher" {
  name = "kube_grenade_project_rancher"
}

resource "openstack_networking_network_v2" "network" {
  name           = "kube_grenade_project_rke2_main_cluster"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  network_id      = openstack_networking_network_v2.network.id
  cidr            = local.network_cidr
  dns_nameservers = ["10.0.0.3"]
}

resource "openstack_networking_router_v2" "router" {
  name                = "kube_grenade_project_rke2_main_cluster"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  name = "kube_grenade_project_rke2_main_cluster"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ext_icmp" {
  description       = "External ICMP"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_int_all_ipv4" {
  description       = "All internal IPv4"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.secgroup.id
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_int_all_ipv6" {
  description       = "All internal IPv6"
  direction         = "ingress"
  ethertype         = "IPv6"
  remote_group_id   = openstack_networking_secgroup_v2.secgroup.id
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_int_ip_all_ipv4" {
  description       = "All internal IPv4 (by IP)"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = local.network_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_rancher_all_ipv4" {
  description       = "All IPv4 from Rancher"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = data.openstack_networking_secgroup_v2.rancher.id
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_rancher_all_ipv6" {
  description       = "All IPv6 from Rancher"
  direction         = "ingress"
  ethertype         = "IPv6"
  remote_group_id   = data.openstack_networking_secgroup_v2.rancher.id
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
