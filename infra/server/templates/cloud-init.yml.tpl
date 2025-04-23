#cloud-config
write_files:
- content: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACD/2kLhNXvlHZAcsvFGGuKqpWppfJMF0cLdMcljsMbiBgAAAKjsTUy17E1M
    tQAAAAtzc2gtZWQyNTUxOQAAACD/2kLhNXvlHZAcsvFGGuKqpWppfJMF0cLdMcljsMbiBg
    AAAEDxOZuOW9OtYKkAzaRhVFEFS/TvlvixvKeBiX8rRDa7nP/aQuE1e+UdkByy8UYa4qql
    aml8kwXRwt0xyWOwxuIGAAAAImt1cnV5aWFAS3VydXlpYXMtTWFjQm9vay1Qcm8ubG9jYW
    wBAgM=
    -----END OPENSSH PRIVATE KEY-----
  path: /root/id_cloud_init
  owner: root:root
  permissions: '0600'
- content: |
   [${role}]
   localhost
  path: /root/inventory
  owner: root:root
  permissions: '0644'
- content: |
    ${indent(4, yamlencode(extra_vars))}
  path: /root/extra_vars.yaml
  owner: root:root
  permissions: '0644'

ansible:
  package_name: ansible-core
  install_method: distro
  pull:
    url: git@github.com:BioTheWolff/kube-grenade.git
    playbook_name: infra/server/ansible/playbook.yml
    private_key: /root/id_cloud_init
    accept_host_key: true
    inventory: /root/inventory
    connection: local
    extra_vars: "@/root/extra_vars.yaml"
