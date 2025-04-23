output "rancher_url" {
  value = rancher2_bootstrap.admin.url
}

output "rancher_username" {
  value = rancher2_bootstrap.admin.user
}

output "rancher_password" {
  value     = rancher2_bootstrap.admin.current_password
  sensitive = true
}
