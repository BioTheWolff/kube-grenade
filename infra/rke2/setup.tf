import {
  to = rancher2_node_driver.openstack
  id = "openstack"
}

resource "rancher2_node_driver" "openstack" {
  builtin = true
  active  = true
  name    = "openstack"
  url     = "local://"
}

resource "rancher2_cloud_credential" "openstack" {
  name        = "openstack"
  description = "Main credentials for OpenStack"

  openstack_credential_config {
    password = ""
  }
}
