# automation-infra

Essa automação é separada em 4 pilares da infraestrutura, sendo eles:
- Computação (EC2, Security Group, Elastic IP)
- Rede (VPC, subnets, Internet Gateway, NAT Gateway, rotas)
- Armazenamento (S3, Glue Database, Athena WorkGroup, Lambda)
- Mensageria (SNS: tópico e subscrição e-mail)

Sujeito a melhorias.

Arquitetura, stack, decisões técnicas e recursos externos de toda a solução: [doc.md](doc.md).

## Backend (instância privada)
A `PrivateInstance` sobe via UserData o backend Spring Boot (Kotlin) e um MySQL 8 com `docker compose`, em `/opt/backend`. O backend vem da imagem pública `izabellefigueiredo1/primelead-backend:latest` do Docker Hub (precisa ser `linux/amd64`). O banco é criado a partir de `database_sql/primelead_automation_script.sql`.

- **Variáveis exigidas pelo `automation_bash.sh`:** `GITHUB_TOKEN` (leitura em `database_sql`) e `DB_PASSWORD` (mínimo 8 caracteres).
  ```bash
  export GITHUB_TOKEN=github_pat_xxx DB_PASSWORD='senha-forte'
  ./automation_bash.sh
  ```
- **Acesso:** API em `http://<PrivateInstancePrivateIp>:8081/api/v1`, só de dentro da VPC (ex.: n8n na instância pública). O MySQL não é exposto.
- **Logs:** `/var/log/userdata-backend.log` e `cd /opt/backend && docker compose logs -f`.
- **Atualizar:** publique a nova `latest` no Docker Hub, entre por SSH pela instância pública e rode `cd /opt/backend && docker compose pull && docker compose up -d`.

## E-mail do SNS (ETL)
- **Sucesso** — Assunto: `ETL OK — {etapa}`. Corpo: texto fixo de sucesso, etapa, status, objetos S3 do disparo (se houver) e resumo (buckets/env, RequestId, função).
- **Erro** — Assunto: `[URGENTE] Erro na ETL — {etapa}`. Corpo: texto fixo de erro, etapa, código do erro e mensagem. 