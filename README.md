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
```

### Runtime classes
TODO


## Cluster security
This section ensures the cluster is properly secured against most attacks.

### Kyverno's policies
The policies are the following:
- `pod-probes`: ensures all pods have liveness and readiness probes
- `resource-limits`: all pods' containers must have resource limits
- `security-context`: add several security context elements to all pods and containers

Apply the policies:
```sh
kubectl apply -Rf kubernetes/kyverno/
```

### Network Policies
TODO

### Istio/Envoy
- [`mTLS`](https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/): ensure trafic is encrypted when possible and is always encrypted to the database
- [`rate limiting`](https://istio.io/latest/docs/tasks/policy-enforcement/rate-limit/): rate limit on the database