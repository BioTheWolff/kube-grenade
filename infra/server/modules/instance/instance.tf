resource "openstack_compute_instance_v2" "instance" {
  name            = var.name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.keypair
  security_groups = [var.secgroup]

  user_data = templatefile(var.user_data_path, {
    role       = var.role,
    extra_vars = merge(var.ansible_extra_vars, {
      public_ip = openstack_networking_floatingip_v2.fip.address,
    }),
  })

  network {
    uuid = var.network_id
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = "public"
}

data "openstack_networking_port_v2" "fip_port" {
  device_id  = openstack_compute_instance_v2.instance.id
  network_id = var.network_id
}

resource "openstack_networking_floatingip_associate_v2" "fip" {
  port_id     = data.openstack_networking_port_v2.fip_port.id
  floating_ip = openstack_networking_floatingip_v2.fip.address
}
