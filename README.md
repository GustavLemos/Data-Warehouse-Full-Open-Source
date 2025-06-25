# 🧱 Data Platform com Airbyte, Airflow, DBT e PostgreSQL

Este projeto implementa uma arquitetura moderna de dados usando ferramentas open source para ingestão, orquestração e transformação de dados, integradas em uma infraestrutura containerizada via Docker Compose.

---

## 📌 Componentes Principais

- **Airbyte**: Ingestão de dados de múltiplas fontes (S3, Oracle, SQL Server etc.)
- **Apache Airflow**: Orquestração de DAGs de ingestão e transformação
- **DBT (Data Build Tool)**: Transformações SQL versionadas e testadas
- **PostgreSQL**: Data warehouse relacional para armazenamento e consultas
- **pgAdmin**: Interface gráfica para PostgreSQL
- **Docker Compose**: Orquestração dos containers
- **Power BI**: Visualização dos dados finais (consumo externo)
- **OpenMetadata**: Catálogo de dados e governança (não incluído neste deploy)

---

## 🏗️ Estrutura da Arquitetura

```

\[S3 / Oracle / SQL Server]
↓
\[Airbyte]
↓
\[PostgreSQL (Landing Zone)]
↓
\[DBT / Airflow]
↓
\[PostgreSQL (Persistence Zone)]
↓
\[Power BI]

```

---

## 📁 Estrutura do Projeto

```

.
├── airflow/
│   ├── dags/
│   ├── logs/
│   └── plugins/
├── dbt/
│   └── dbt\_project/
├── docker-compose.yml
└── README.md

````

---

## 🚀 Como Subir o Projeto

### 1. Pré-requisitos

- Docker e Docker Compose instalados
- Instância EC2 com porta 8080 (Airflow), 5050 (pgAdmin), 5432 (PostgreSQL) liberadas

### 2. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
````

### 3. Subir os containers

```bash
docker-compose up -d
```

---

## 🔑 Acesso aos Serviços

| Serviço    | URL                                            | Usuário           | Senha   |
| ---------- | ---------------------------------------------- | ----------------- | ------- |
| Airflow    | [http://localhost:8080](http://localhost:8080) | `admin`           | `admin` |
| pgAdmin    | [http://localhost:5050](http://localhost:5050) | `admin@admin.com` | `admin` |
| PostgreSQL | `localhost:5432` (via cliente)                 | `admin`           | `admin` |

---

## 🧠 Organização das DAGs

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

## 🛠️ Comandos Úteis

* **Ver logs**:
  `docker-compose logs -f airflow-webserver`

* **Parar containers**:
  `docker-compose down`

* **Executar DBT manualmente** (opcional):

  ```bash
  docker exec -it dbt bash
  dbt run
  ```

---

## 🧪 Testes e Qualidade

* Modelos DBT com testes integrados
* PRs com validação antes de merge
* Airflow com monitoramento de DAGs

---

## 📚 Padrão de Nomenclatura

* **Schemas de ingestão**: `ingestion_<domínio>_<squad>_<entidade>`
* **Schemas finais**: `<domínio>_<squad>_<entidade>_final`
* **DAGs**: `dag_<frequência>_<domínio>_<entidade>`

---

## 👁️ Observabilidade

* Logs no Airflow
* Monitoramento via Grafana (não incluído neste repositório)
* Integração futura com CloudWatch / Prometheus

---

## 📌 Roadmap Futuro

* Integração com OpenMetadata
* Deploy contínuo via Azure DevOps
* Escalabilidade para ECS ou EKS
* Pipeline automatizado de backup/restore

---

## 👤 Autor

**Gustavo Lemos**
Arquiteto de Dados
Data da última atualização: 24/06/2025


```
