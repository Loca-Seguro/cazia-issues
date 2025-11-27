# users_and_access.tf

locals {
  # Mapeia as chaves lógicas ('ops', 'dev', 'app_users') para os SLUGS reais criados no GitHub
  # Use os slugs exatos, que geralmente são minúsculos e sem hifens, baseados nos nomes do screenshot.
  team_slug_map = {
    "ops"       = "caziaopstriage",
    "dev"       = "caziadevengenharia",
    "app_users" = "caziaappusers",
    "Admins"    = "caziasuperadmins"
  }

  # Definição dos repositórios e permissões (A estrutura do seu antigo locals)
  cazia_teams_config = {
    "Admins" = {
      repos = { 
      (github_repository.cazia_project_repo.name) = "admin",
      (github_repository.main.name) = "admin" }
    },
    "ops" = {
      repos = { (github_repository.main.name) = "maintain" }
    },
    "dev" = {
      repos = { 
        (github_repository.cazia_project_repo.name) = "push",
        (github_repository.main.name) = "push" }
    },
    "app_users" = {
      repos = {
        (github_repository.main.name)               = "pull",
        (github_repository.cazia_project_repo.name) = "pull"
      }
    }
  }
}

# BUSCA TIMES EXISTENTES: Consulta os times criados manualmente via SLUG
data "github_team" "cazia_teams_data" {
  for_each = local.team_slug_map
  slug     = each.value
}

# Substitua este bloco pelo seu original (o bloco de criação de team deve ser removido)
# Garanta que o bloco github_team_membership seja removido ou comentado, 
# pois ele também depende da criação do time.

# 3. Gerencia o acesso de cada time aos seus repositórios (AGORA USANDO DATA)
resource "github_team_repository" "team_repo_access" {
  for_each = merge([
    for team_key, team_data in local.cazia_teams_config : {
      for repo_name, permission in team_data.repos :
      "${team_key}-${repo_name}" => {
        team_key   = team_key
        repository = repo_name
        permission = permission
      }
    }
  ]...)

  # REFERÊNCIA ATUALIZADA: Puxa o ID do time através do Data Source
  team_id    = data.github_team.cazia_teams_data[each.value.team_key].id
  repository = each.value.repository
  permission = each.value.permission
}

