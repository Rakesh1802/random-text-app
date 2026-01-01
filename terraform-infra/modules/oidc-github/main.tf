# Create the User-Assigned Managed Identity
resource "azurerm_user_assigned_identity" "github_oidc" {
  location            = var.location  # Choose your region
  name                = "oidc-github-${var.location}" # Your desired identity name
  resource_group_name = var.primary_rg_name # Where you want to store this identity
}

# Register the "App" Trust (Federated Credential)
# This tells Azure: "Trust tokens from THIS specific GitHub repo and branch"
resource "azurerm_federated_identity_credential" "github_trust" {
  name                = "github-actions-trust"
  resource_group_name = azurerm_user_assigned_identity.github_oidc.resource_group_name
  parent_id           = azurerm_user_assigned_identity.github_oidc.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  
  # CRITICAL: This limits access to ONE specific repo and branch
  # Format: repo:<OrgName>/<RepoName>:ref:refs/heads/<BranchName>
  subject             = "repo:${var.github_org_name}/${var.github_repo_name}:ref:refs/heads/main"
}

# Grant access to the entire Resource Groups
resource "azurerm_role_assignment" "resource_group_access" {
  for_each = {
    primary   = var.primary_rg_id
    secondary = var.secondary_rg_id
  }

  scope                = each.value
  role_definition_name = "Website Contributor"
  principal_id         = azurerm_user_assigned_identity.github_oidc.principal_id
}

