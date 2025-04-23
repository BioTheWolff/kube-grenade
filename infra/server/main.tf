resource "openstack_compute_keypair_v2" "keypair" {
  name = "kube_grenade_project_rancher"
}

resource "random_password" "rancher_initial_password" {
  length  = 16
  special = false
}

resource "local_sensitive_file" "private_key" {
  content  = openstack_compute_keypair_v2.keypair.private_key
  filename = "${path.module}/ansible/generated/keyfile"
}

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/ansible_inventory.yml.tpl",
    {
      rancher_node_ip            = module.rancher_node.public_ipv4
      rancher_bootstrap_password = random_password.rancher_initial_password.result
    }
  )

  filename = "${path.module}/ansible/generated/inventory.yml"
}

module "rancher_node" {
  source = "./modules/instance"

  name           = "kube_grenade_project_rancher_server"
  keypair        = openstack_compute_keypair_v2.keypair.name
  secgroup       = openstack_networking_secgroup_v2.secgroup.name
  network_id     = openstack_networking_network_v2.network.id
  user_data_path = "${path.module}/templates/cloud-init.yml.tpl"
  role           = "rancher_node"

  ansible_extra_vars = {
    rancher_bootstrap_password = random_password.rancher_initial_password.result
  }
}
