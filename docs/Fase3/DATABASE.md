# 🗄️ Modelagem de Banco de Dados - Oficina Mecânica

Documentação do modelo relacional e dicionário de dados da base MySQL 8.0 (AWS RDS).

---

## 📐 Diagrama de Entidade-Relacionamento (ER)

+-------------------+          +-------------------+
|      CLIENTS      |          |     VEHICLES      |
+-------------------+          +-------------------+
| PK  id            |1        *| PK  id            |
|     cpf (UQ)      |<--------+| FK  client_id     |
|     name          |          |     license_plate |
|     email         |          |     brand         |
|     phone         |          |     model         |
+-------------------+          |     year          |
                               +-------------------+
                                         | 1
                                         |
                                         | *
                               +-------------------+
                               |  SERVICE_ORDERS   |
                               +-------------------+
                               | PK  id            |
                               | FK  vehicle_id    |
                               |     status        |-- [ DIAGNOSTICO | EXECUCAO | FINALIZADO | PAGO ]
                               |     total_amount  |
                               |     notes         |
                               |     created_at    |
                               |     updated_at    |
                               +-------------------+
                                         | 1
                                         |
                                         | *
                               +-------------------+
                               |   SERVICE_ITEMS   |
                               +-------------------+
                               | PK  id            |
                               | FK  service_order_id
                               |     type          |-- [ PECA | MAO_DE_OBRA ]
                               |     description   |
                               |     quantity      |
                               |     unit_price    |
                               +-------------------+

---

## 📋 Dicionário de Dados

### 1. Tabela `customers`
* `id` (BIGINT, PK, Auto-Increment): Identificador único.
* `document` (VARCHAR(11), Unique, Not Null): CPF do cliente (usado na autenticação).
* `name` (VARCHAR(255), Not Null): Nome completo do cliente.
* `email` (VARCHAR(255), Not Null): E-mail do cliente.

### 2. Tabela `vehicles`
* `id` (BIGINT, PK, Auto-Increment): Identificador único do veículo.
* `client_id` (BIGINT, FK -> clients.id): Proprietário do veículo.
* `license_plate` (VARCHAR(10), Not Null): Placa do veículo.
* `model` (VARCHAR(100), Not Null): Modelo do automóvel.

### 3. Tabela `service_orders`
* `id` (BIGINT, PK, Auto-Increment): Identificador único da Ordem de Serviço.
* `vehicle_id` (BIGINT, FK -> vehicles.id): Veículo em manutenção.
* `status` (ENUM, Not Null): Status da OS (`DIAGNOSTICO`, `EXECUCAO`, `FINALIZADO`, `PAGO`).
* `total_amount` (DECIMAL(10,2)): Valor total dos serviços e peças.

### 4. Tabela `service_items`
* `id` (BIGINT, PK, Auto-Increment): Identificador do item da OS.
* `service_order_id` (BIGINT, FK -> service_orders.id): Ordem de serviço vinculada.
* `type` (ENUM, Not Null): Categoria (`PECA` ou `MAO_DE_OBRA`).
* `description` (VARCHAR(255), Not Null): Descrição do item/serviço.
* `unit_price` (DECIMAL(10,2), Not Null): Valor unitário.