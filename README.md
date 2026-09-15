# 🍕 Tech Challenge - Aplicação Principal (Laravel API)

A aplicação principal do ecossistema **Tech Challenge**, responsável pelo gerenciamento de pedidos, produtos e clientes. O projeto roda sob uma arquitetura de containers orquestrada por **Kubernetes (K3s)** em uma instância AWS EC2, conectada a um banco **AWS RDS MySQL** e integrada a uma função **AWS Lambda** para autenticação.

---
## 📐 Arquitetura Geral da Solução

```mermaid
flowchart TD
    classDef client fill:#e1f5fe,stroke:#0288d1,stroke-width:2px,color:#01579b;
    classDef aws fill:#fff3e0,stroke:#f57c00,stroke-width:2px,color:#e65100;
    classDef k8s fill:#e8f5e9,stroke:#388e3c,stroke-width:2px,color:#1b5e20;
    classDef cicd fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#4a148c;

    Client["👤 Usuário / Cliente Final"]:::client

    subgraph AWS_Cloud ["☁️ AWS Academy Learner Lab (us-east-1)"]
        subgraph Gateway_Layer ["🚪 Camada de Entrada & Autenticação"]
            APIGW["🌐 AWS API Gateway v2 (HTTP API)"]:::aws
            AuthLambda["⚡ AWS Lambda (tc-soat-auth-lambda)"]:::aws
        end

        subgraph Compute_Layer ["🖥️ Instância EC2 (Amazon Linux 2023)"]
            subgraph K3s_Cluster ["☸️ Cluster K3s (Kubernetes)"]
                Ingress["🌐 K3s Ingress / Traefik"]:::k8s
                subgraph App_Pod ["📦 Pod: tc-app-laravel"]
                    Laravel["🍕 Container Laravel (PHP 8.2 / Apache)"]:::k8s
                end
                ConfigSecret["🔑 ConfigMap & Secret"]:::k8s
            end
        end

        subgraph Database_Layer ["🗄️ Camada de Persistência"]
            RDS["🐬 AWS RDS MySQL 8.0 (db.t3.micro)"]:::aws
        end
    end

    subgraph GitHub_Ecosystem ["🐙 GitHub Ecosystem"]
        GHA_Infra["⚙️ GitHub Actions (tc-soat-k8s-infra)"]:::cicd
        GHA_DB["⚙️ GitHub Actions (tc-soat-db-infra)"]:::cicd
        GHA_App["⚙️ GitHub Actions (tech-challenge)"]:::cicd
        GHCR["📦 GitHub Container Registry"]:::cicd
    end

    Client -->|1. Requisição HTTP/HTTPS| APIGW
    APIGW -->|2. POST /auth - Validar Token| AuthLambda
    APIGW -->|3. Roteamento de Tráfego| Ingress
    Ingress -->|4. Encaminha para o Pod| Laravel

    ConfigSecret -.->|Injeta Variáveis do RDS| Laravel
    Laravel -->|5. Consultas e Migrations - Porta 3306| RDS

    GHA_Infra ==>|Terraform Apply e Setup K3s| AWS_Cloud
    GHA_DB ==>|Terraform Apply| RDS
    GHA_App ==>|Build e Push Image| GHCR
    GHA_App ==>|SSH Deploy e Rollout| K3s_Cluster
    GHCR -.->|Pull Imagem Container| App_Pod
```

---

## 📚 Documentação de Arquitetura

Para acessar as RFCs, ADRs e o Diagrama ER do Banco de Dados[cite: 1]:
👉 [Acessar Pasta /docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)

## 🛠️ Tecnologias Utilizadas

* **Framework Backend:** PHP 8.2 / Laravel 10
* **Containerização:** Docker & GitHub Container Registry (`ghcr.io`)
* **Orquestrador:** K3s (Kubernetes leve) em AWS EC2 (`t2.micro` / Amazon Linux 2023)
* **Persistência de Dados:** AWS RDS MySQL 8.0 (`db.t3.micro`)
* **CI/CD:** GitHub Actions (`appleboy/ssh-action`)

---

## 🔑 Configuração de Secrets (GitHub Actions)

Para viabilizar a pipeline de CI/CD deste repositório, cadastre as seguintes Secrets em **Settings > Secrets and variables > Actions**:

| Secret | Descrição |
| :--- | :--- |
| `EC2_PUBLIC_IP` | Endereço IP público atual da instância EC2 (K3s Node) |
| `EC2_SSH_KEY` | Conteúdo completo da chave privada SSH (`vockey.pem`) |
| `GITHUB_TOKEN` | Token padrão de autenticação do GitHub (usado para publicar e puxar imagens do GHCR) |

---

## 🔄 Fluxo da Pipeline CI/CD

1. **Build & Push:** Compila a imagem Docker do Laravel e publica no `ghcr.io/william-moura/tech-challenge:master`.
2. **Auto-healing & Bootstrap do K3s:** Conecta via SSH na EC2. Caso o K3s ou os manifestos base ainda não estejam presentes na instância, executa a instalação do K3s e o apply dos manifestos base do repositório `tc-soat-k8s-infra`.
3. **Rollout da Aplicação:** Reinicia o deployment `tc-app-laravel` com a imagem atualizada e aguarda o status do Pod ficar `Running`.
4. **Execução Automática de Migrations:** Executa o comando `php artisan migrate --force` diretamente dentro do container ativo no K3s.

---

## 🧪 Execução Local com Docker Compose

Caso deseje testar a aplicação localmente sem dependência da nuvem:

```bash
# 1. Iniciar os containers da aplicação e do banco de dados
docker-compose up -d --build

# 2. Executar as migrations
docker-compose exec app php artisan migrate

# 3. Limpar caches do Laravel
docker-compose exec app php artisan config:clear