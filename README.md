# Kube Grenade
This project is created under the course "Advanced Orchestration" of Polytech DO5.
More description TODO.

## Whiteapp
The Whiteapp is a rust simple web application composed of a frontend, a backend and a database. The frontend contact the backend, which pull 2 words from the database. The backend sends the words to the frontend, which displays them.

## Installation
This section defines the resources and how to install them.

### RKE2
The Kubernetes distribution used in this project is RKE2. It is deployed through
Rancher to our OpenStack, using Terraform.

For more details, read [the README file in the `infra/` directory](./infra/README.md).

All system applications are deployed with the cluster as additional manifests
through Terraform. Equivalent commands will be provided below to install them.

The cluster is deployed as two machine pools: one for the control plane and
etcd, and another one for the workers. Each machine pool has 3x VMs with 4 GB
of memory and 4 vCPUs.

### Cilium
Cilium is installed with the cluster using Rancher's preset.

### Kyverno
Installation with the Helm Chart:

```sh
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

Values:

```yaml
reportsController:
  rbac:
    clusterRole:
      extraResources:
        - apiGroups:
            - apps
          resources:
            - deployments/scale
```

### Monitoring
The monitoring stack is deployed with [`kube-prometheus-stack`](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md),
which installs and configures Prometheus and Grafana.

Installation with the Helm Chart:

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

### KubeArmor
Installation with the Helm Chart:

```sh
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update
helm install kubearmor-operator kubearmor/kubearmor-operator -n kubearmor --create-namespace
```

A `KubeArmorConfig` resource is also deployed. See [here](https://github.com/BioTheWolff/kube-grenade/blob/main/infra/rke2/manifests/files/kubearmor.yml).

### Istio and Kiali
Installation with the Helm Chart and Istio addon:

```sh
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm install istiod istio/istiod -n istio-system
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/addons/kiali.yaml
```

### Argo CD
For our CD system, we chose to deploy Argo CD in the cluster and configure it
to watch the manifest files present in the [`kubernetes/workloads/app/`](./kubernetes/workloads/app/)
directory.

Argo CD is installed using its Helm Chart:

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace
helm install argocd-apps argo/argocd-apps -n argocd
```

Values used for those installations can be found [here](infra/rke2/manifests/files/argocd.yml)
and [here](infra/rke2/manifests/files/argocd-apps.yml).

Basically, the following is configured:

- A Git repository pointing to this repo
- A project for deploying our application, with the following restrictions:
    - Apps in this project can only be sourced from the previously-configured repo
    - Apps can only be deployed to the `app-namespace` namespace
    - Apps cannot apply any cluster-wide resources
    - Apps can only apply `Deployment`, `Ingress` and `Service` resources
- An app in the previously-configured project that deploys resources from the
  [`kubernetes/workloads/app/`](./kubernetes/workloads/app/) directory in this repo

### Whiteapp
This section details how to install the whiteapp into the cluster, and to setup necessary components in order for the red team to attack.

#### PostgreSQL
Install postgresql in the database namespace:
```sh
kubectl create ns db-namespace
kubectl apply -n db-namespace -Rf kubernetes/workloads/database/manifests/
helm install app-db oci://registry-1.docker.io/bitnamicharts/postgresql -f kubernetes/workloads/database/values.helm.yml --namespace db-namespace
```

#### Utils
This installs the necessary configmaps so that the app may know how to reach the database:
```sh
kubectl create ns app-namespace
kubectl apply -n app-namespace -Rf kubernetes/workloads/utils
```

#### Deploy the app itself
If you want to try out the sample app, you can deploy it yourself:
```sh
kubectl apply -n app-namespace -Rf kubernetes/workloads/app
```

## Cluster security
This section ensures the cluster is properly secured against most attacks.

### Kyverno's policies
The policies are the following:
- `pod-probes`: ensures all pods have liveness and readiness probes
- `resource-limits`: all pods' containers must have resource limits
- `require-nonroot`: all containers must run as non-root
- `restrict-container`: restrict the number of containers in a pod
- `restrict-scale`: restrict the number of replicas in a deployment
- `restrict-volume-types`: restrict the volume types that can be used
- `security-context`: add several security context elements to all pods and containers
- `block-large-images`: block images larger than 1Gb

### Network Policies
Turns-out, network policies were not really useful for this project, as the name of the backend app could change in our scenario. However, for the sake of completeness, here are the network policies we would have used:
- `lock-db`: restrict the traffic to the database to only the backend

### Istio/Envoy
- [`mTLS`](https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/): ensure trafic is encrypted when possible and is always encrypted to the database
- [`rate limiting`](https://istio.io/latest/docs/tasks/policy-enforcement/rate-limit/): rate limit on the database
