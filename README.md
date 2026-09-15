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
            APIGW["🌐 AWS API Gateway v2 (HTTP API)\n[tc-soat-k8s-infra]"]:::aws
            AuthLambda["⚡ AWS Lambda\n(tc-soat-auth-lambda)"]:::aws
        end

        subgraph Compute_Layer ["🖥️ Instância EC2 (t2.micro / Amazon Linux 2023)"]
            subgraph K3s_Cluster ["☸️ Cluster K3s (Kubernetes)"]
                Ingress["🌐 K3s Ingress / Traefik\n(Porta 80)"]:::k8s
                subgraph App_Pod ["📦 Pod: tc-app-laravel"]
                    Laravel["🍕 Container Laravel\n(PHP 8.2 / Apache)"]:::k8s
                end
                ConfigSecret["🔑 ConfigMap & Secret\n(Env Variables)"]:::k8s
            end
        end

        subgraph Database_Layer ["🗄️ Camada de Persistência"]
            RDS["🐬 AWS RDS MySQL 8.0\n(db.t3.micro)\n[tc-soat-db-infra]"]:::aws
        end
    end

    subgraph GitHub_Ecosystem ["🐙 GitHub Ecosystem"]
        GHA_Infra["⚙️ GitHub Actions\n(tc-soat-k8s-infra)"]:::cicd
        GHA_DB["⚙️ GitHub Actions\n(tc-soat-db-infra)"]:::cicd
        GHA_App["⚙️ GitHub Actions\n(tech-challenge)"]:::cicd
        GHCR["📦 GitHub Container Registry\n(ghcr.io)"]:::cicd
    end

    Client -->|1. Requisição HTTP/HTTPS| APIGW
    APIGW -->|2. POST /auth\nValidar Token| AuthLambda
    APIGW -->|3. Roteamento de Tráfego| Ingress
    Ingress -->|4. Encaminha para o Pod| Laravel

    ConfigSecret -.->|Injeta Variáveis do RDS| Laravel
    Laravel -->|5. Consultas & Migrations\n(Porta 3306)| RDS

    GHA_Infra ==>|Terraform Apply & Setup K3s| AWS_Cloud
    GHA_DB ==>|Terraform Apply| RDS
    GHA_App ==>|Build & Push Image| GHCR
    GHA_App ==>|SSH Deploy & Rollout| K3s_Cluster
    GHCR -.->|Pull Imagem Container| App_Pod