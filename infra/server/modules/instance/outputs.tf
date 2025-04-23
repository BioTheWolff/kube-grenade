output "instance_ipv4" {
  value       = openstack_compute_instance_v2.instance.access_ip_v4
  description = "The private IPv4 address of the OpenStack instance"
}

output "public_ipv4" {
  value       = openstack_networking_floatingip_v2.fip.address
  description = "The public IPv4 address of the OpenStack instance"
}
