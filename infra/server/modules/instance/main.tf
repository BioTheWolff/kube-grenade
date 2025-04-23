data "openstack_images_image_v2" "image" {
  name = var.instance_image
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.instance_flavor
}
