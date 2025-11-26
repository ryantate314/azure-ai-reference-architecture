# https://github.com/Azure-Samples/microsoft-foundry-baseline/blob/main/infra-as-code/bicep/azure-policies.bicep

locals {
  ai_services_should_have_key_access_disabled = "71ef260a-8f18-47b7-abcb-62d0673d94dc"
  ai_services_should_restrict_network_access = "037eea7a-bd0a-46c5-9a66-03aea78705d3"
  ai_search_should_disable_public_network_access = "ee980b6d-0eca-4501-8d54-f6290fd512c3"
  ai_search_should_have_local_auth_disabled = "6300012e-e9a4-4649-b41f-a85f5c43be91"
  storage_accounts_should_disable_public_network_access = "b2982f36-99f2-4db5-8eff-283140c09693"
  storage_accounts_should_prevent_shared_key_access = "8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54"

  policies = [{
    name = "AI Services Should Have Key Access Disabled"
    definition_id = local.ai_services_should_have_key_access_disabled
  },
  {
    name = "AI Services Should Restrict Network Access"
    definition_id = local.ai_services_should_restrict_network_access
  },
  {
    name = "AI Search Should Disable Public Network Access"
    definition_id = local.ai_search_should_disable_public_network_access
  },
  {
    name = "AI Search Should Have Local Auth Disabled"
    definition_id = local.ai_search_should_have_local_auth_disabled
  },
  {
    name = "Storage Accounts Should Disable Public Network Access"
    definition_id = local.storage_accounts_should_disable_public_network_access
  },
  {
    name = "Storage Accounts Should Prevent Shared Key Access"
    definition_id = local.storage_accounts_should_prevent_shared_key_access
  }]
}

resource "azurerm_subscription_policy_assignment" "assignment" {
  for_each = { for policy in local.policies : policy.name => policy }

  name = each.key
  subscription_id = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/${each.value.definition_id}"
  parameters = jsonencode({
    effect = {
      value = try(each.value.effect, "Audit")
    }
  })
}
