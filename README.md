# Gerenciamento de Instâncias EC2 na AWS

![TQI](https://github.com/user-attachments/assets/8e63b328-1333-4a08-945b-43cb041cc59f)

> **Bootcamp TQI — Modernização com GenAI**
> Laboratório prático de administração de ambientes EC2 com automação via AWS CLI e infraestrutura como código com Terraform.

---

## 1. Problema de Negócio

Equipes de engenharia que operam workloads na AWS frequentemente enfrentam um risco silencioso: **a ausência de processos reprodutíveis para o ciclo de vida de instâncias EC2**.

Sem um fluxo estruturado para criar AMIs, registrar snapshots e lançar instâncias a partir de imagens versionadas, a operação fica vulnerável a:

- Perda irrecuperável de estado em caso de falha de instância;
- Replicação manual e propensa a erros de ambientes de produção;
- Incapacidade de rollback rápido após uma atualização problemática;
- Ausência de rastreabilidade sobre o que estava rodando e quando.

A pergunta que este projeto responde é direta: **como garantir que qualquer instância EC2 possa ser recriada de forma segura, rápida e padronizada?**

---

## 2. Contexto

Este repositório foi desenvolvido como laboratório do **Bootcamp TQI – Modernização com GenAI**, dentro de um módulo dedicado à administração de infraestrutura AWS.

O escopo cobre o ciclo completo de gerenciamento de instâncias EC2:

| Dimensão | O que foi abordado |
|---|---|
| Backup de imagens | Criação e gerenciamento de AMIs |
| Backup de volumes | Snapshots EBS e restauração |
| Replicação de ambiente | Launch de instâncias a partir de AMIs |
| Automação | Scripts Bash via AWS CLI |
| Infraestrutura como Código | Terraform para provisioning reprodutível |
| Documentação técnica | Guia completo de operações e boas práticas |

O projeto nasceu de uma necessidade real observada em ambientes cloud: times que sabem *usar* a AWS, mas não têm processos formalizados para *proteger e recriar* seus recursos.

---

## 3. Premissas da Análise

Para estruturar as soluções deste laboratório, foram adotadas as seguintes premissas operacionais:

- **AMIs são a unidade de backup de instâncias** — representam o estado completo do sistema operacional e das configurações instaladas.
- **Snapshots EBS são o backup de volumes de dados** — independentes da instância, persistem mesmo após o encerramento da mesma.
- **Scripts Bash assumem AWS CLI v2 configurado** — com credenciais e região definidos via `aws configure`.
- **O código Terraform parte de um estado limpo** — não há remote state configurado; o ambiente assume execução local para fins de laboratório.
- **Segurança é premissa, não afterthought** — o `.gitignore` foi configurado desde o início para excluir chaves `.pem`, arquivos `.tfstate` e variáveis sensíveis.

---

## 4. Estratégia da Solução

A solução foi estruturada em três camadas complementares:

### Camada 1 — Automação Operacional (`/scripts`)

Scripts Bash para operações recorrentes de EC2, cada um com validação de parâmetros e retorno do ID do recurso criado:

| Script | Operação | Comando |
|---|---|---|
| `create_ami.sh` | Cria AMI a partir de instância existente | `./create_ami.sh <INSTANCE_ID> <AMI_NAME>` |
| `create_snapshot.sh` | Cria snapshot de volume EBS | `./create_snapshot.sh <VOLUME_ID> <DESCRIPTION>` |
| `restore_volume_from_snapshot.sh` | Restaura volume a partir de snapshot | `./restore_volume_from_snapshot.sh <SNAPSHOT_ID> <AZ>` |
| `launch_instance_from_ami.sh` | Lança instância a partir de AMI | `./launch_instance_from_ami.sh <AMI_ID> <TYPE> <KEY> <SG> <SUBNET>` |

Cada script foi construído com a filosofia de **operação idempotente** — pode ser executado múltiplas vezes sem efeitos colaterais indesejados, desde que os parâmetros sejam os mesmos.

### Camada 2 — Infraestrutura como Código (`/terraform`)

Arquivos Terraform que permitem subir o mesmo ambiente de forma reprodutível em qualquer conta AWS:

```hcl
resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "EC2-Gerenciada-Terraform"
  }
}
```

A separação entre `main.tf` e `variables.tf` foi uma decisão deliberada: qualquer pessoa pode mudar região, tipo de instância ou AMI sem tocar na lógica principal da infraestrutura.

### Camada 3 — Documentação Técnica (`/docs`)

- `EC2_AMI_Snapshot_Guide.md` — guia completo de operações, do conceito à execução
- `imagens_e_comentarios.md` — registro visual e comentários do laboratório

---

## 5. Insights Técnicos

> *Esta seção documenta o que não estava óbvio no início — decisões não triviais e armadilhas que encontrei ao longo do laboratório.*

**Por que Bash e não Python para os scripts?**
Avaliei usar `boto3` para as operações de automação. Optei por Bash + AWS CLI pela aderência direta aos comandos da documentação oficial da AWS e pela portabilidade imediata em qualquer ambiente Linux sem dependências de runtime Python. O trade-off é que Bash tem tratamento de erros mais limitado — algo que `boto3` resolveria melhor em produção.

**O risco do `.gitignore` tardio**
Uma lição importante: o `.gitignore` precisa ser criado *antes* do primeiro commit. Neste projeto, o arquivo foi incluído desde o início para garantir que chaves `.pem`, arquivos `.tfstate` e `.tfvars` com credenciais nunca chegassem ao repositório. Em projetos reais, esse erro é irreversível — o histórico do Git guarda o que foi commitado, mesmo que o arquivo seja removido depois.

**Terraform sem remote state é um laboratório, não produção**
A configuração local do Terraform é suficiente para estudos, mas em times reais o `terraform.tfstate` precisa estar em um backend remoto (S3 + DynamoDB Lock). Deixei isso explícito como próximo passo para não criar a ilusão de que o código, como está, está pronto para produção.

**AMIs e custos ocultos**
AMIs armazenam snapshots dos volumes associados. Criar AMIs sem uma política de retenção gera custos crescentes e invisíveis no EBS. Para este laboratório documentei a necessidade de deregistrar AMIs antigas junto com a deleção dos snapshots correspondentes.

---

## 6. Resultados

Ao final do laboratório, o repositório entrega:

- **4 scripts Bash funcionais** cobrindo o ciclo completo de backup e restauração de instâncias EC2
- **Infraestrutura como código** com Terraform para provisioning reprodutível e parametrizável
- **Guia técnico completo** de operações AMI e EBS acessível a times não especialistas
- **Estrutura de repositório segura** com `.gitignore` configurado para ambientes cloud

O resultado principal não é o código em si, mas a **formalização de um processo**: qualquer instância EC2 deste ambiente pode ser recriada, restaurada ou replicada em minutos, com rastreabilidade e sem dependência de memória operacional.

---

## 7. Aprendizados

Entrei neste laboratório confortável com o console da AWS e saí com uma clareza que não tinha antes: **clicar no console e automatizar são habilidades diferentes**.

O que mais me surpreendeu foi a quantidade de decisões implícitas que o console toma por você — região padrão, tipo de volume, opções de retenção — e que precisam ser explícitas nos scripts. Isso me fez entender por que times de SRE documentam tudo: o conhecimento que fica na cabeça do operador é um risco operacional.

Se fosse começar hoje, teria estruturado o Terraform com remote state desde o início, mesmo para laboratório. O hábito de fazer certo em ambiente de estudo é o que forma o instinto de fazer certo em produção.

---

## 8. Próximos Passos

- [ ] Migrar o estado do Terraform para backend S3 + DynamoDB Lock
- [ ] Adicionar política de retenção automática de AMIs via Lambda + EventBridge
- [ ] Implementar tags padronizadas (ambiente, responsável, data de criação) em todos os recursos
- [ ] Criar pipeline de CI/CD com GitHub Actions para validação (`terraform validate` + `terraform plan`) a cada PR
- [ ] Expandir os scripts com tratamento de erros via `set -euo pipefail` e logging estruturado

---

## Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| AWS EC2 | Criação e gerenciamento de instâncias |
| AWS EBS | Snapshots e volumes persistentes |
| AWS CLI v2 | Automação via linha de comando |
| Bash Shell | Scripts de operação e automação |
| Terraform 1.x | Infraestrutura como código |
| Git + GitHub | Versionamento e repositório |

---

## Pré-requisitos

**Local:**
- Git
- AWS CLI v2 configurado (`aws configure`)
- Terraform 1.x
- Bash (Linux / macOS / WSL no Windows)

**Na AWS:**
- Conta AWS ativa
- IAM User com permissões: `ec2:RunInstances`, `ec2:CreateImage`, `ec2:CreateSnapshot`, `ec2:RegisterImage`, `ec2:AttachVolume`, `ec2:Describe*`

---

## Como Executar

```bash
# Clone o repositório
git clone https://github.com/Santosdevbjj/gerenciaInstanciaEC2
cd gerenciaInstanciaEC2

# Dê permissão de execução aos scripts
chmod +x scripts/*.sh

# Exemplo: criar uma AMI
./scripts/create_ami.sh i-0abc123def456 minha-ami-backup

# Exemplo: provisionar infraestrutura com Terraform
cd terraform
terraform init
terraform plan
terraform apply
```

---

## Estrutura do Repositório

```
gerenciaInstanciaEC2/
├── scripts/
│   ├── create_ami.sh
│   ├── create_snapshot.sh
│   ├── restore_volume_from_snapshot.sh
│   └── launch_instance_from_ami.sh
├── terraform/
│   ├── main.tf
│   └── variables.tf
├── docs/
│   ├── EC2_AMI_Snapshot_Guide.md
│   └── imagens_e_comentarios.md
├── images/
│   └── captura_tela.png
├── .gitignore
└── README.md
```

---

<br>



---

**Contato:**

[![Portfólio Sérgio Santos](https://img.shields.io/badge/Portfólio-Sérgio_Santos-111827?style=for-the-badge&logo=githubpages&logoColor=00eaff)](https://portfoliosantossergio.vercel.app)

[![LinkedIn Sérgio Santos](https://img.shields.io/badge/LinkedIn-Sérgio_Santos-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/santossergioluiz) 

---

