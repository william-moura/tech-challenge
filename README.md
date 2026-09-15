---

### 3. `tech-challenge` (Aplicação Principal Laravel)

Crie ou atualize o arquivo **`README.md`** neste repositório:

```markdown
# 🍕 Tech Challenge - Aplicação Principal (Laravel API)

Repositório da aplicação backend desenvolvida em **PHP/Laravel**, orquestrada em containers Docker e publicada no cluster **K3s (AWS EC2)**.

---

## 📦 Funcionalidades & Arquitetura

* **Framework:** Laravel 10 / PHP 8.2
* **Banco de Dados:** MySQL 8.0 (AWS RDS)
* **Container Registry:** GitHub Container Registry (`ghcr.io`)
* **Orquestrador:** Kubernetes (K3s em AWS EC2)

---

## ⚙️ Fluxo da Pipeline CI/CD (GitHub Actions)

A pipeline automatizada realiza a entrega contínua nos seguintes passos:

1. **Build & Push Docker Image:** Gera a imagem Docker da aplicação e publica no GHCR com as tags `:latest` e `:${{ github.sha }}`.
2. **Auto-healing & Bootstrap do K3s:** Conecta via SSH (`appleboy/ssh-action`) na EC2 e valida a integridade do K3s. Se a instância tiver sido recriada pelo Terraform, reinstala o K3s e faz o bootstrap dos manifestos base automaticamente.
3. **Rollout Atualizado:** Executa `kubectl rollout restart deployment/tc-app-laravel` com a nova imagem Docker do GHCR.
4. **Automated Database Migrations:** Após os pods estarem no estado `Running`, executa automaticamente `php artisan migrate --force` dentro do pod.

---

## 🛠️ Configuração de Secrets do Repositório

| Secret | Descrição |
| :--- | :--- |
| `EC2_PUBLIC_IP` | IP público atual da instância EC2 (K3s Node) |
| `EC2_SSH_KEY` | Chave privada SSH (`vockey.pem`) |
| `GITHUB_TOKEN` | Token automático do GitHub para pull no GHCR |

---

## 🧪 Execução Local com Docker Compose

Para testar e rodar a aplicação localmente:

```bash
# 1. Subir os containers do Laravel e MySQL
docker-compose up -d --build

# 2. Executar as migrations do banco
docker-compose exec app php artisan migrate

# 3. Limpar e atualizar caches
docker-compose exec app php artisan config:clear