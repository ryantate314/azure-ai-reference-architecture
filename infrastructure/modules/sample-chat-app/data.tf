data "azuread_group" "devs" {
  display_name = var.security_group_name
}