terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.8.3"
    }
  }
}

# Configuração do Provedor GitHub
provider "github" {
  owner = var.org_name
  token = var.token
}

# Data Source para obter o ID da Organização (Necessário para Projects V2)
data "github_organization" "current" {
  name = var.org_name
}

# ==============================================================================
# 1. Mapeamento de Arquivos Locais para Destinos no Repositório
# ==============================================================================

locals {
  # Arquivos de configuração do Terraform (*.tf) que devem ir para a pasta 'github-iac/'
  
  # Definição centralizada de todos os rótulos de Scrum/Desenvolvimento
  cazia_dev_labels = {
    # Tipos de Trabalho
    "work_epic" = {
      name  = "work: epic"
      color = "974F9F" # Roxo Escuro
      desc  = "Uma grande iniciativa que será dividida em Histórias de Usuário."
    }
    "work_story" = {
      name  = "work: story"
      color = "0E8A16" # Verde (Pode substituir ou coexistir com 'type: feature')
      desc  = "Unidade de trabalho implementável, sob um Épico."
    }
    "work_task" = {
      name  = "work: task"
      color = "F7D024" # Amarelo (Fácil de identificar no board)
      desc  = "Tarefa técnica, não entregável, necessária para completar uma Story."
    }
    
    "feature" = {
      name  = "type: feature"
      color = "0E8A16" # Verde
      desc  = "Nova funcionalidade (User Story) a ser implementada."
    }
    "spike" = {
      name  = "type: spike"
      color = "A2ABF2" # Roxo Claro
      desc  = "Pesquisa de engenharia para reduzir incerteza antes do desenvolvimento."
    }
    "refactor" = {
      name  = "type: refactor"
      color = "0072C6" # Azul
      desc  = "Melhoria de código existente que não adiciona nova funcionalidade ao usuário."
    }
    # Estimativas (Sizing / Story Points)
    "size_s" = {
      name  = "size: S (1 SP)"
      color = "B8B8B8" # Cinza Claro
      desc  = "Estimativa: Pequena (1 Story Point)."
    }
    "size_m" = {
      name  = "size: M (3 SP)"
      color = "909090" # Cinza Médio
      desc  = "Estimativa: Média (3 Story Points)."
    }
    "size_l" = {
      name  = "size: L (5 SP)"
      color = "686868" # Cinza Escuro
      desc  = "Estimativa: Grande (5 Story Points)."
    }
    # Rastreamento de Sprint
    "sprint_current" = {
      name  = "sprint: current"
      color = "2A9D8F" # Teal
      desc  = "Item selecionado e planejado para ser concluído na Sprint atual."
    }
  }
  
  iac_files = {
    for filename in fileset(path.module, "*.tf") :
    "github-iac/${filename}" => filename
  }

  # Arquivos de Template (.yml) que devem ir para '.github/ISSUE_TEMPLATE/'
  template_yml_files = {
    for filename in fileset("${path.module}/templates", "*.yml") :
    ".github/ISSUE_TEMPLATE/${filename}" => "templates/${filename}"
  }

  # NOVO MAPA: Mapeia TODOS os templates para a subpasta de código-fonte IaC
  templates_in_iac_folder = {
    for filename in fileset("${path.module}/templates", "*.{yml,tpl}") :
    "github-iac/templates/${filename}" => "templates/${filename}"
  }
 
  functional_templates = {
    ".github/ISSUE_TEMPLATE/config.yml" : "templates/config.tpl" 
  }

  # Arquivos de Template (.tpl) que devem ir para a raiz do repositório
  template_root_files = {
    #"CONTRIBUTING.md" : "templates/contributing.tpl"
    "README.md" : "templates/README.tpl",
    "SECURITY.md" : "templates/SECURITY.tpl"
  }

  # Workflows (Serão carregados via templatefile/file())
  workflow_files_map = {
    ".github/workflows/telegram_notify.yml" : "templates/telegram_notify.yml" ,
    ".github/workflows/slack_notify.yml" : "templates/slack_notify.yml"
  }

  # Combinação de todos os arquivos
  config_files = merge(local.functional_templates, local.iac_files, local.template_yml_files, local.template_root_files,local.templates_in_iac_folder, local.workflow_files_map)
}

# ==============================================================================
# 2. Recursos Essenciais do Repositório
# ==============================================================================

resource "github_repository" "main" {
  name                   = var.repo_name
  description            = "Repositório do projeto Cazia, configurado com Issues as Code."
  visibility             = "public"
  has_issues             = true
  has_projects           = true
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
  
  auto_init              = true 
}


# resource "github_repository" "cazia_project_repo"
resource "github_repository" "cazia_project_repo" {
  name                   = var.project_name
  description            = "Repositório dedicado ao desenvolvimento de novas funcionalidades (Features) e planejamento de sprints do Cazia."
  visibility             = "public" # ou "private", dependendo da necessidade
  
  # HABILITADO: Essencial para rastrear e planejar features
  has_issues             = true
  has_projects           = true 
  
  # CONTROLE DE MERGE: Padrão para desenvolvimento profissional
  allow_merge_commit     = false   # Desativado: Força merges limpos (Squash ou Rebase)
  allow_squash_merge     = true    # Ativado: Ótimo para merges de feature branches com histórico limpo
  allow_rebase_merge     = true    # Ativado: Permite manter o histórico linear
  delete_branch_on_merge = true    # Limpeza automática

  auto_init              = true 
}

# Garante a criação explícita da branch 'main' antes de tentar comitar arquivos
resource "github_branch" "main" {
  repository    = github_repository.main.name
  branch        = "main"
  source_branch = "main"
  depends_on    = [github_repository.main]
}

# Gerenciamento de Rótulos (Com a sintaxe HCL corrigida)
resource "github_issue_labels" "cazia_labels" {
  repository = github_repository.main.name

  # Rótulos de Tipo
  label {
    name        = "type: bug"
    color       = "d73a4a"
    description = "Algo não está funcionando ou está incorreto."
  }

  label {
    name        = "status: blocked"
    color       = "e11d21" # Cor Vermelha de Alerta
    description = "A issue está bloqueada por uma dependência externa (cliente, legal, API)."
  }

  label {
    name        = "type: enhancement"
    color       = "a2ee62"
    description = "Nova funcionalidade ou solicitação de melhoria."
  }
  label {
    name        = "type: documentation"
    color       = "0075ca"
    description = "Melhorias ou adições à documentação."
  }

  # Rótulos de Estado
  label {
    name        = "state: duplicate"
    color       = "cfd3d7"
    description = "Esta issue ou pull request já existe."
  }
  label {
    name        = "state: invalid"
    color       = "e4e669"
    description = "Reporte incompleto ou incorreto."
  }
  label {
    name        = "state: wontfix"
    color       = "ffffff"
    description = "Não será trabalhado."
  }

  # Rótulos de Colaboração e Triagem
  label {
    name        = "good first issue"
    color       = "7057ff"
    description = "Boa para novos contribuidores."
  }
  label {
    name        = "help wanted"
    color       = "008672"
    description = "Precisa de atenção extra da comunidade/equipe."
  }
  label {
    name        = "to triage"
    color       = "f9d0c4"
    description = "Issue nova que precisa de revisão e categorização."
  }
}

# ==============================================================================
# 3. Upload Dinâmico de TODOS os Arquivos (IaC, Templates e Workflows)
# ==============================================================================

resource "github_repository_file" "all_files" {
  for_each = local.config_files

  repository = github_repository.main.name
  branch     = github_branch.main.branch
  file       = each.key

  # Lógica de Conteúdo: Se o arquivo for .tpl, USA templatefile. Caso contrário (.tf, .yml), usa file().
  content = endswith(each.value, ".tpl") ? templatefile(
    "${path.module}/${each.value}", 
    {
      repo_name    = var.repo_name
      org_name     = var.org_name
      search_link  = "https://github.com/${var.org_name}/${var.repo_name}/issues"
    }
  ) : file("${path.module}/${each.value}")

  commit_message      = "feat: Adiciona arquivo de configuração: ${each.key}"
  overwrite_on_create = true
  depends_on          = [github_branch.main] 
}
# ==============================================================================
# 4. Gerenciamento de Secrets do GitHub Actions
# ==============================================================================

resource "github_actions_secret" "telegram_token_secret" {
  repository      = github_repository.main.name
  secret_name     = "TELEGRAM_TOKEN"
  plaintext_value = var.telegram_token
  
  depends_on      = [github_repository.main] 
}

resource "github_actions_secret" "telegram_chat_id_secret" {
  repository      = github_repository.main.name
  secret_name     = "TELEGRAM_CHAT_ID"
  plaintext_value = var.telegram_chat_id
  
  depends_on      = [github_repository.main]
}


# NOVO Bloco (Substitui os antigos secrets do Telegram)
resource "github_actions_secret" "slack_webhook_secret" {
  repository      = github_repository.main.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = var.slack_webhook
  depends_on      = [github_repository.main]
}


# Cria todos os rótulos de desenvolvimento usando o loop for_each
resource "github_issue_label" "cazia_dev_labels" {
  for_each = local.cazia_dev_labels

  # Certifique-se de que 'cazia_project_repo' é o nome do seu recurso do novo repositório
  repository  = github_repository.cazia_project_repo.name
  name        = each.value.name
  color       = each.value.color
  description = each.value.desc
}

# # LOCALIZAR ESTE BLOCO NO main.tf (Linhas 209 em diante, aproximadamente)
# resource "github_repository_security_and_analysis" "cazia_security_settings" {
#   repository_id = github_repository.main.node_id 

#   # Deixamos o Advanced Security e o Secret Scanning desabilitados,
#   # mas este recurso garante que a página de segurança seja configurada.
#   advanced_security {
#     status = "disabled"
#   }
#   secret_scanning {
#     status = "disabled"
#   }
#   secret_scanning_push_protection {
#     status = "disabled"
#   }
# }