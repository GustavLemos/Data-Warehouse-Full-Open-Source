# Documentação Técnica: Arquitetura de Dados com Airbyte, Airflow, DBT e PostgreSQL

**Autor:** Gustavo Lemos dos Santos (Arquiteto de Dados)  
**Data:** 24/06/2025

---

## Sumário

1. [Visão Geral da Arquitetura](#1-visão-geral-da-arquitetura)  
2. [Componentes Principais](#2-componentes-principais)  
3. [Relacionamento entre Componentes](#3-relacionamento-entre-componentes)  
4. [Deploy no EC2 com Docker Compose](#4-deploy-no-ec2-com-docker-compose)  
5. [Requisitos de Rede e Acesso](#5-requisitos-de-rede-e-acesso)  

---

## 1. Visão Geral da Arquitetura

A arquitetura contempla uma esteira de ingestão, transformação e disponibilização de dados baseada em:

- Extração com **Airbyte**
- Orquestração com **Apache Airflow**
- Transformações SQL com **DBT**
- Armazenamento em **PostgreSQL** via **Amazon RDS**
- Visualização via **Power BI**
- Governança com **OpenMetadata**
- Infraestrutura versionada com **GitHub**, **Docker** e **Azure DevOps**

---

## 2. Componentes Principais

### 🔸 Fontes de Dados

- **AWS S3** – Dados brutos em arquivos JSON/parquet.
- **Oracle / SQL Server** – Bancos relacionais legados.

---

### 🔹 Airbyte

Ferramenta de **EL**(Extract and Loading Only) para ingestão de dados com conectores prontos.

- Executa DAGs de ingestão própria sem necessidade do uso do Airflow.
- Insere dados na **Landing Zone** no PostgreSQL.

---

### 🔹 Apache Airflow

Motor de orquestração que coordena os pipelines de:

- Transformação (DBT)
- Geração de relatórios e paralelização com outras ferramentas se necessário

Utiliza DAGs organizadas em pastas por frequência e domínio.

---

### 🔹 DBT (Data Build Tool)

Executa transformações SQL em cima dos dados da Landing Zone e gera modelos na **Persistence Zone**:

- `models/` contém os arquivos `.sql` com lógica de negócio.
- `dbt_project.yml` define estrutura e configurações de ambiente.

---

### 🔹 PostgreSQL (Amazon RDS)

Serve como:

- Armazenamento da **Landing Zone**
- Banco intermediário e final da **Persistence Zone**
- Base para consumo por Power BI e outros consumidores

---

### 🔹 Power BI

Consome os dados transformados no schema final do PostgreSQL para geração de relatórios e dashboards.

---

### 🔹 OpenMetadata

Catálogo de dados para:

- Documentação técnica
- Nomenclatura de schemas
- Governança de ativos

---

### 🔹 Azure DevOps / GitHub

- Repositório de DAGs e arquivos DBT
- Pipelines de CI/CD para atualização de artefatos no EC2 via Docker

---

## 3. Relacionamento entre Componentes

```plaintext
[S3 / Oracle / SQL Server]
         |
     [Airbyte] --> [PostgreSQL: landing]
         |
     [Airflow DAG de Ingestão]
         |
     [DBT (via DAG de Transformação)]
         |
     [PostgreSQL: persistence] --> [Power BI / Consumo]
         |
 [OpenMetadata] cataloga schemas e ativos
````

* As DAGs do Airflow executam as etapas de ingestão e transformação.
* DBT transforma os dados e organiza em camadas semânticas.
* Os dados finalizados são consumidos por ferramentas de BI.

---

## 4. Deploy no EC2 com Docker Compose

### 🔧 Pré-requisitos

* Instância EC2 (Amazon Linux ou Ubuntu)
* Docker e Docker Compose instalados
* Porta 8080 (Airflow), 5050 (pgAdmin), 5432 (Postgres) liberadas no Security Group

### 📦 Etapas

#### 1. Instalar Docker e Docker Compose

```bash
# Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
exit  # reconectar

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2. Subir ambiente

Estrutura de diretórios esperada:

```
project/
├── airflow/
│   ├── dags/
│   ├── logs/
│   └── plugins/
├── dbt/
│   └── dbt_project/
├── docker-compose.yml
```

Com o arquivo `docker-compose.yml` fornecido, execute:

```bash
cd project/
docker-compose up -d
```

#### 3. Acessos

* Airflow: `http://<ip_publico>:8080`
* pgAdmin: `http://<ip_publico>:5050`
* PostgreSQL: `5432` (usar com DBT e pgAdmin)

---

## 5. Requisitos de Rede e Acesso

### 🔐 Portas a liberar no Security Group da EC2:

| Porta | Serviço        |
| ----- | -------------- |
| 22    | SSH            |
| 8080  | Airflow Web UI |
| 5050  | pgAdmin        |
| 5432  | PostgreSQL     |

### 👤 Acesso

* Airflow: usuário criado via DAG de inicialização (`admin:admin`)
* pgAdmin: `admin@admin.com` / `admin`
* DBT: usa conexão via `profiles.yml` para conectar ao Postgres
* Dados são organizados em:

  * `landing_dominio_squad_entidade`
  * `dominio_squad_entidade_final`

---

## 6. Organização de DAGs

```
airflow/dags/
├── ingestion/
│   ├── dag_diaria.py
│   ├── dag_semanal.py
│   └── dag_mensal.py
├── transformation/
│   ├── dag_dbt_clientes.py
│   └── dag_dbt_vendas.py
```

---

## 7. Observabilidade

* **Grafana:** leitura de logs e métricas do Airflow e Postgres
* **CloudWatch:** monitoramento de custos e uso
* **Secrets Manager:** armazenar senhas sensíveis

---

## 8. Exemplo de Execução DBT

```sql
-- models/dominio_squad_atividade_usuarios.sql
WITH base AS (
  SELECT *
  FROM {{ ref('raw_usuarios') }}
)
SELECT
  id,
  COUNT(*) AS acessos,
  RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_atividade
FROM base
GROUP BY id
```

---

## 9. Repositório e CI/CD

* Código versionado em Git
* Pull requests disparam pipelines no Azure DevOps via action
* Atualizações são empacotadas com Docker e aplicadas no EC2

**Importe: configurar um git clone deste repositório inicialmente no ec2 com os serviços funcionais e para Pull Requests de novas dags e dbt procedures desenvolver um action para realizar um pull no repositório já presente no EC2 e realizar uma atualização dos containers DBT e Airflow Squeduler**

**Importante: Em nível de Poc está sendo utilizado o postgreSQL em container, mas recomenda-se que seja usado um RDS Aurora Aws em casos de ambiente de produção além de uma possível estratégia de não segregar todos os containers dentro de um EC2 apenas.**

---

## 10. Governança

* Nome de schemas:

  * `ingestion_dominio_squad_entidade`
  * `dominio_squad_entidade_final`
* Todos os ativos são catalogados no OpenMetadata

---


