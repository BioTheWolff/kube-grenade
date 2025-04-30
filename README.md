# Kube Grenade
This project is created under the course "Advanced Orchestration" of Polytech DO5.
More description TODO.

## Whiteapp
TODO


## Installation
This section defines the resources and how to install them.

### RKE2
TODO

### Cilium
TODO

### Kyverno
Simple one-liner installation:
```sh
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.13.0/install.yaml
kubectl apply -Rf kubernetes/kyverno/
```

### Runtime classes
TODO

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
- `security-context`: add several security context elements to all pods and containers
- `block-large-images`: block images larger than 1Gb

### Network Policies
TODO

### Istio/Envoy
- [`mTLS`](https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/): ensure trafic is encrypted when possible and is always encrypted to the database
- [`rate limiting`](https://istio.io/latest/docs/tasks/policy-enforcement/rate-limit/): rate limit on the database
