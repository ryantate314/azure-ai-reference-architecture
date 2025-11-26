output "bastion_password" {
  description = "The password for the Bastion host VM."
  value       = module.shared_infrastructure.bastion_password
}