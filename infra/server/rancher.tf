resource "rancher2_bootstrap" "admin" {
  initial_password = random_password.rancher_initial_password.result
}

resource "local_file" "rancher_credentials" {
  content = templatefile("${path.module}/templates/rancher.sh.tpl",
    {
      rancher_url       = rancher2_bootstrap.admin.url
      rancher_token_key = rancher2_bootstrap.admin.token
    }
  )

  filename = "${path.module}/../rke2/generated/rancher.sh"
}
