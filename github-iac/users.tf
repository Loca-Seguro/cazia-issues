# Gerenciamento de Usuários, Times e Permissões (IaC)

# ==============================================================================
# 1. DEFINIÇÃO DE LOCALS (Dados Centralizados)
# ==============================================================================

locals {
  # Definição dos times, repositórios que eles acessam, e seus membros
  # NOTA: Os nomes dos repositórios são referências a recursos criados em outro lugar (ex: main.tf)
  cazia_teams_config = {
    "ops" = {
      name        = "Cazia-Ops-Triage"
      description = "Time responsável pela triagem e suporte do repositório principal."
      repos = {
        # Referência ao Repositório Principal (Ex: cazia-project)
        (github_repository.main.name) = "maintain" 
      }
      # Lista de usuários (usuários do GitHub)
      members = ["user_ops_lead", "Lucas Ribeiro"] 
    },
    "dev" = {
      name        = "Cazia-Dev-Engenharia"
      description = "Time responsável pelo desenvolvimento e sprints do repositório de features."
      repos = {
        # Referência ao Repositório de Desenvolvimento (Ex: cazia-project-features)
        (github_repository.cazia_project_repo.name) = "push" 
      }
      # Lista de usuários (usuários do GitHub)
      members = ["LucasPaivaLoca", "Poluxin21", "rosthancazia"] 
    }
  }
}

# ==============================================================================
# 2. CRIAÇÃO DOS TIMES (Grupos)
# ==============================================================================

# Cria os Times (Teams) na Organização GitHub
resource "github_team" "cazia_teams" {
  for_each = local.cazia_teams_config

  name        = each.value.name
  description = each.value.description
  privacy     = "secret" # Recomendado para times internos
}

# ==============================================================================
# 3. GERENCIAMENTO DE ACESSO AO REPOSITÓRIO (Permissões)
# ==============================================================================

# Gerencia o nível de permissão de cada time nos seus respectivos repositórios
resource "github_team_repository" "team_repo_access" {
  for_each = merge([
    for team_key, team_data in local.cazia_teams_config : {
      for repo_name, permission in team_data.repos :
      "${team_key}-${repo_name}" => {
        team_slug  = github_team.cazia_teams[team_key].slug
        repository = repo_name
        permission = permission
      }
    }
  ]...)

  team_id    = github_team.cazia_teams[each.value.team_slug].id
  repository = each.value.repository
  permission = each.value.permission
}

# ==============================================================================
# 4. GERENCIAMENTO DE MEMBROS (Associação de Usuários)
# ==============================================================================

resource "github_team_membership" "team_members" {
  for_each = merge([
    # Loop externo: Itera sobre cada time
    for team_key, team_data in local.cazia_teams_config : {
      # Loop interno: Itera sobre os membros DENTRO desse time
      for username in distinct(compact(team_data.members)) :
      # Chave de Saída (Única): "team_key-username" => Valor (Objeto de Membro)
      "${team_key}-${username}" => {
        username  = username
        team_slug = github_team.cazia_teams[team_key].slug
      }
    }
  ]...) # O splat operator (...) e merge() achatam a lista de mapas em um mapa único

  team_id  = github_team.cazia_teams[each.value.team_slug].id
  username = each.value.username
  role     = "member"
}