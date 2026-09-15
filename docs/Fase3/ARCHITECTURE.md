# 🏛️ Documentação de Arquitetura - Tech Challenge (Fase 3)

Este diretório contém a documentação técnica, decisões arquiteturais e modelagem de dados do sistema da **Oficina Mecânica**.

---

## 📑 Índice de Documentos

* **Documentação do Banco de Dados:**
  * [Diagrama ER & Modelo Relacional](./DATABASE.md)

* **Requests for Comments (RFCs):**
  * [RFC 001 - Autenticação Serverless com CPF e JWT](./RFC-001.md)
  * [RFC 002 - Segregação de Repositórios e Pipelines CI/CD](./RFC-002.md)

* **Architecture Decision Records (ADRs):**
  * [ADR 001 - Escolha do Banco de Dados Gerenciado (AWS RDS MySQL)](./ADR-001.md)
  * [ADR 002 - Orquestrador Kubernetes K3s em AWS EC2](./ADR-002.md)
  * [ADR 003 - Estratégia de Observabilidade e Centralização de Logs](./ADR-003.md)

---

## 🔗 Visão dos Repositórios Integrados

1. **Lambda (Function Serverless):** `tc-soat-auth-lambda`
2. **Infraestrutura Kubernetes (Terraform):** `tc-soat-k8s-infra`
3. **Infraestrutura do Banco de Dados (Terraform):** `tc-soat-db-infra`
4. **Aplicação Principal (Laravel API):** `tech-challenge`