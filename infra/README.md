# Rancher deployment

This directory contains the Terraform stack and Ansible playbook that can be
used to deploy a k3s cluster with Rancher installed onto it, and another
Terraform stack to create an RKE2 cluster on Rancher with OpenStack.

The following services are pre-installed on the RKE2 cluster:

- The
  [openstack-cloud-controller-manager](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md)
  cloud provider, to implement services of LoadBalancer type
- The [Cinder CSI
  Driver](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/cinder-csi-plugin/using-cinder-csi-plugin.md),
  to provide storage backed by OpenStack Cinder for Persistent Volumes
- Argo CD, configured to install apps from the [`apps/`](../apps/) directory of
  this repository

## Prerequisites

You'll need to install the following tools:

- [Terraform](https://developer.hashicorp.com/terraform/install) (tested with Terraform v1.10.2)

You'll also need to download [your `x-openrc.sh` file from
OpenStack](https://horizon-openstack.apps.osp.do.intra/dashboard/project/api_access/openrc/),
and then source it to configure the environment variables needed by the
OpenStack Terraform provider:

```sh
source ./x-openrc.sh
```

## Deploy Rancher to OpenStack

This part assumes that you are located in the [`server/`](./server/) directory.

### Preparation

Initialize the Terraform working directory:

```sh
terraform init
```

### Deploy the infrastructure

You can deploy the infrastructure with Terraform as usual:

```sh
terraform apply
```

**Note:** on first set up, Terraform may fail to configure Rancher if the
instance takes too long to start up and configure itself. In that case, simply
start Terraform again until it succeeds.

### Destroy the infrastructure

You can destroy the infrastructure with Terraform as usual:

```sh
terraform destroy
```

## Access Rancher

Once the infrastructure is deployed and configured, the Rancher web interface
should be available at `https://<RANCHER_VM_IP>.sslip.io/`.

You can get all the information necessary to connect to the Rancher web
interface by looking at the outputs of the Rancher Terraform stack:

```sh
$ cd server/
$ terraform output -raw rancher_url     
https://<RANCHER_VM_IP>.sslip.io

$ terraform output -raw rancher_username
admin

$ terraform output -raw rancher_password
<RANCHER_PASSWORD>
```

## Access Argo CD

You can access the Argo CD web interface by port-forwarding its server to your
local host:

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

The Argo CD web interface will be available at http://localhost:8080/.

The default Argo CD password for the `admin` user can be fetched from the
cluster:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

An example application is already deployed for you to play with.

## Create an RKE2 cluster on Rancher

This part assumes that you are located in the [`rke2/`](./rke2/) directory.

### Preparation

First, source the previously generated shell script to set the environment
variables needed to authenticate to Rancher:

```sh
source ./generated/rancher.sh
```

Then, initialize the Terraform working directory:

```sh
terraform init
```

### Create the cluster

You can create the cluster with Terraform as usual:

```sh
terraform apply
```

### Destroy the cluster

You can destroy the cluster with Terraform as usual:

```sh
terraform destroy
```
