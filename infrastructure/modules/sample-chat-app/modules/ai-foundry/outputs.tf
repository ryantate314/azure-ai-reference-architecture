output "project_endpoint" {
  description = "The endpoint URL for the deployed AI model."
  value       = "https://${module.ai_foundry.ai_foundry_name}.services.ai.azure.com/api/projects/${local.project_name}"
}