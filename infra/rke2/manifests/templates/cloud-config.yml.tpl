apiVersion: v1
kind: Secret
metadata:
  name: cloud-config
  namespace: kube-system
type: Opaque
stringData:
  cloud.conf: |
    [Global]
    auth-url=${auth_url}
    application-credential-id=${application_credential_id}
    application-credential-secret=${application_credential_secret}
    region=${region}
    tls-insecure=true

    [LoadBalancer]
    subnet-id=${subnet_id}
    floating-network-id=${floating_network_id}
