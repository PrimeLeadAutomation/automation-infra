# automation-infra

Essa automação é separada em 4 pilares da infraestrutura, sendo eles:
- Computação (EC2, Security Group, Elastic IP)
- Rede (VPC, subnets, Internet Gateway, NAT Gateway, rotas)
- Armazenamento (S3, Glue Database, Athena WorkGroup, Lambda)
- Mensageria (SNS: tópico e subscrição e-mail)

Sujeito a melhorias.

## Backend (instância privada)
A `PrivateInstance` sobe via UserData o backend Spring Boot (Kotlin) e um MySQL 8 com `docker compose`, em `/opt/backend`. O banco é criado a partir de `database_sql/primelead_automation_script.sql`.

- **Variáveis exigidas pelo `automation_bash.sh`:** `GITHUB_TOKEN` (leitura em `back-end` e `database_sql`) e `DB_PASSWORD` (mínimo 8 caracteres).
  ```bash
  export GITHUB_TOKEN=ghp_xxx DB_PASSWORD='senha-forte'
  ./automation_bash.sh
  ```
- **Acesso:** API em `http://<PrivateInstancePrivateIp>:8080`, só de dentro da VPC (ex.: n8n na instância pública). O MySQL não é exposto.
- **Logs:** `/var/log/userdata-backend.log` e `cd /opt/backend && docker compose logs -f`.
- **Atualizar:** SSH pela instância pública, depois `cd /opt/backend/back-end && git pull` (com token) e `cd .. && docker compose up -d --build`.

## E-mail do SNS (ETL)
- **Sucesso** — Assunto: `ETL OK — {etapa}`. Corpo: texto fixo de sucesso, etapa, status, objetos S3 do disparo (se houver) e resumo (buckets/env, RequestId, função).
- **Erro** — Assunto: `[URGENTE] Erro na ETL — {etapa}`. Corpo: texto fixo de erro, etapa, código do erro e mensagem. 