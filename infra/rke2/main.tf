locals {
  identity_service    = [for entry in data.openstack_identity_auth_scope_v3.scope.service_catalog:
                             entry if entry.type=="identity"][0]
  identity_endpoint   = [for endpoint in local.identity_service.endpoints:
                             endpoint if (endpoint.interface=="public" && endpoint.region=="regionOne")][0]
  identity_public_url = local.identity_endpoint.url
}

data "openstack_identity_auth_scope_v3" "scope" {
  name = "my_scope"
}

resource "openstack_identity_application_credential_v3" "rancher" {
  name         = "kube_grenade_project_rancher_rke2_main_cluster"
  description  = "Credentials for the main RKE2 cluster in Rancher"
}

resource "openstack_identity_application_credential_v3" "rke2" {
  name         = "kube_grenade_project_rke2_main_cluster"
  description  = "Credentials for the main RKE2 cluster"
}

resource "rancher2_machine_config_v2" "ctrl_pool" {
  generate_name = "ctrl-pool"

  openstack_config {
    application_credential_id     = openstack_identity_application_credential_v3.rancher.id
    application_credential_secret = openstack_identity_application_credential_v3.rancher.secret
    auth_url                      = local.identity_public_url
    availability_zone             = ""
    boot_from_volume              = true
    flavor_name                   = "m1.medium"
    image_name                    = "OpenSUSE-Leap-15"
    insecure                      = true
    net_id                        = openstack_networking_network_v2.network.id
    region                        = data.openstack_identity_auth_scope_v3.scope.region
    sec_groups                    = openstack_networking_secgroup_v2.secgroup.id
    ssh_user                      = "ec2-user"
    volume_size                   = 50
  }
}

resource "rancher2_cluster_v2" "rke2" {
  name                  = "main"
  kubernetes_version    = "v1.32.3+rke2r1"
  enable_network_policy = false

  rke_config {
    machine_global_config = yamlencode({
      cni = "cilium"
    })

    machine_selector_config {
      config = yamlencode({
        cloud-provider-name   = "external"
        cloud-provider-config = ""
      })
    }

    additional_manifest = join(
      "\n---\n",
      concat(
        [for filepath in fileset(path.module, "manifests/files/*.yml"): file(filepath)],
        [
          // cloud.conf secret
          templatefile("${path.module}/manifests/templates/cloud-config.yml.tpl",
            {
              auth_url                      = local.identity_public_url
              application_credential_id     = openstack_identity_application_credential_v3.rke2.id
              application_credential_secret = openstack_identity_application_credential_v3.rke2.secret
              region                        = data.openstack_identity_auth_scope_v3.scope.region

              subnet_id           = openstack_networking_subnet_v2.subnet.id
              floating_network_id = data.openstack_networking_network_v2.public.id
            }
          ),
        ],
      )
    )

    machine_pools {
      name                         = "ctrl-pool"
      quantity                     = 3
      cloud_credential_secret_name = rancher2_cloud_credential.openstack.id

      control_plane_role = true
      etcd_role          = true
      worker_role        = false

      machine_config {
        kind = rancher2_machine_config_v2.ctrl_pool.kind
        name = rancher2_machine_config_v2.ctrl_pool.name
      }
    }

    machine_pools {
      name                         = "worker-pool"
      quantity                     = 3
      cloud_credential_secret_name = rancher2_cloud_credential.openstack.id

      control_plane_role = false
      etcd_role          = false
      worker_role        = true

      machine_config {
        kind = rancher2_machine_config_v2.ctrl_pool.kind
        name = rancher2_machine_config_v2.ctrl_pool.name
      }
    }
  }
}
