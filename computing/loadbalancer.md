# Load Balancer do Frontend

## Objetivo

O frontend da PrimeLead foi colocado atrás de um Application Load Balancer (ALB) para demonstrar balanceamento HTTP, health checks e escalabilidade horizontal com baixo consumo inicial.

## Arquitetura

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Target Group
   |
   v
Auto Scaling Group do frontend
   +-- 1 instancia normalmente
   +-- 2 instancias durante aumento de carga
```

O ALB usa duas subnets publicas, uma em `us-east-1a` e outra em `us-east-1b`. As instancias do frontend ficam nas duas subnets privadas e recebem trafego somente do Security Group do ALB.

## Escalabilidade

O Auto Scaling Group foi configurado com:

- capacidade minima: 1 instancia;
- capacidade desejada: 1 instancia;
- capacidade maxima: 2 instancias;
- tipo de instancia: `t3.small`;
- politica Target Tracking de CPU com alvo de 60%.

Assim, uma segunda instancia so e criada quando a carga justificar o aumento. Quando a carga diminui, o grupo pode retornar para uma instancia.

## Health check

O Target Group verifica a rota `/` na porta 80. Instancias consideradas indisponiveis deixam de receber trafego pelo ALB.

## Separacao de responsabilidades

Somente o frontend e escalavel. A instancia publica existente continua hospedando Grafana e n8n, enquanto a instancia privada continua hospedando o backend e o banco de dados.

Essa separacao evita duplicar dados do PostgreSQL e volumes locais do n8n em cada nova instancia.

## Provisionamento

O `automation_bash.sh` cria os stacks nesta ordem:

1. `network-stack` cria VPC, subnets e rotas.
2. `message-stack` cria o topico SNS.
3. `compute-stack` cria ALB, ASG, frontend, backend e demais recursos de computacao.
4. `monitoring-stack` cria dashboard e alarmes do ALB.
5. `storage-stack` cria os recursos de armazenamento.

O endereco publico do frontend e o Output `FrontendLoadBalancerDnsName` do `compute-stack`.

## Validacao

Depois do provisionamento, consultar o DNS do ALB e verificar:

```bash
aws cloudformation describe-stacks --stack-name compute-stack
aws autoscaling describe-auto-scaling-groups
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

O Target Group deve apresentar pelo menos uma instancia com estado `healthy`.
