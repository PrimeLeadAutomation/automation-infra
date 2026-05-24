# automation-infra

Essa automação é separada em 4 pilares da infraestrutura, sendo eles:
- Computação (EC2, Security Group, Elastic IP)
- Rede (VPC, subnets, Internet Gateway, NAT Gateway, rotas)
- Armazenamento (S3, Glue Database, Athena WorkGroup, Lambda)
- Mensageria (SNS: tópico e subscrição e-mail)

Sujeito a melhorias.

## E-mail do SNS (ETL)
- **Sucesso** — Assunto: `ETL OK — {etapa}`. Corpo: texto fixo de sucesso, etapa, status, objetos S3 do disparo (se houver) e resumo (buckets/env, RequestId, função).
- **Erro** — Assunto: `[URGENTE] Erro na ETL — {etapa}`. Corpo: texto fixo de erro, etapa, código do erro e mensagem. 