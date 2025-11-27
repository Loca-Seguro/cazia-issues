variable "org_name" {
  description = "O nome da organização ou usuário do GitHub."
  type        = string
  default     = "Loca-Seguro" # Necessário para o Project V2 e links
}

variable "repo_name" {
  description = "O nome do repositório principal."
  type        = string
  default     = "cazia-issues" # Necessário para links e nome do repositório
}

variable "project_name" {
  default = "cazia-planing"
}

variable "token" {
  description = "O Personal Access Token (PAT) do GitHub com permissões de 'repo'."
  type        = string
  sensitive   = true
  default     = ""

}

# Adicionar ao seu variables.tf
variable "telegram_token" {
  description = "Token do bot do Telegram (obtido no BotFather)."
  type        = string
  sensitive   = true
}

variable "telegram_chat_id" {
  description = "ID do chat/grupo/canal do Telegram."
  type        = string
  sensitive   = true
}

# NOVO VALOR EM variables.tf
variable "slack_webhook" {
  description = "URL do Webhook do Slack para notificações (Cazia Channel)."
  type        = string
  sensitive   = true
}