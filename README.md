# 📄 README.md do Projeto Cazia (cazia-issues)

## 🚀 Visão Geral

Este repositório contém o código-fonte principal do Projeto Cazia (CRM/Sistema Imobiliário).

Nossa governança de trabalho é totalmente gerenciada como **Issues as Code (IaC)**, garantindo que a configuração de labels, templates e automação de fluxo de trabalho estejam sempre em sincronia com o Terraform.

## 🛠️ Configuração e Tecnologias

* **Gestão de Issues:** GitHub Issues (Padronizado).
* **Infraestrutura como Código (IaC):** HashiCorp Terraform.
* **Automação Ativa:** Notificações de triagem via **Slack**.
* **Arquivos de Configuração (IaC):** Localizados na pasta `github-iac/`.

## ✅ Guia de Contribuição e Workflow de Issues

### 1. 🔍 Antes de Abrir uma Issue (Melhor Prática)

**É OBRIGATÓRIO** pesquisar por issues duplicadas antes de submeter um novo relatório.
> Você pode pesquisar todas as issues existentes em: [Busca Rápida de Issues](https://github.com/Loca-Seguro/cazia-issues/issues)

### 2. 📝 Tipos de Issues e Templates Específicos

Todas as solicitações devem ser abertas usando um dos *templates* estruturados abaixo. Escolha o template que melhor descreve seu pedido para garantir a triagem correta:

| Template | Finalidade | Rótulo Principal |
| :--- | :--- | :--- |
| **🐛 Falha Crítica ou Bug** | Reportar erros de dados ou falhas que impedem o fluxo de trabalho imobiliário. | `type: bug` |
| **✨ Solicitação Genérica/Melhoria** | Propor novas funcionalidades ou melhorias de UX/UI. | `type: enhancement` |
| **🧑‍💻 Ajuda/Ação Dev (Interna)** | Pedidos de acesso, configuração de ambiente ou apoio técnico à equipe de Dev/TI. | `help wanted` |
| **📚 Feedback de Documentação** | Reportar erros no site, na documentação ou em exemplos. | `type: documentation` |

### 3. Rastreamento e Automação

* **Projetos:** As issues são rastreadas no board de organização: **Cazia-BugTracking**.
* **Notificação:** Ao abrir, atribuir ou priorizar uma issue, uma notificação é enviada para o canal de triagem via Slack.
* **Rótulos Chave:** Utilizamos prefixos `type:` (natureza da issue) e `state:` (situação atual da issue).

## 🛡️ Relatório de Vulnerabilidade e Segurança

**NUNCA abra uma issue pública** para relatar uma vulnerabilidade.

Nosso processo de Divulgação Responsável está totalmente documentado no arquivo **`SECURITY.md`** na raiz deste repositório. Use o canal privado (e-mail) indicado nesse documento.

## ⚙️ Manutenção e Configuração do Terraform

Para aplicar alterações na configuração de Issues, Labels ou Templates, utilize os arquivos na subpasta IaC:

```bash
# Navegue até a pasta de configuração
cd github-iac

# Inicialize o provedor
terraform init

# Execute e aplique as mudanças
terraform apply
