### Gerenciando Instâncias EC2 na AWS.

![TQI](https://github.com/user-attachments/assets/8e63b328-1333-4a08-945b-43cb041cc59f)


**Bootcamp TQI - Modernização com GenAI**

---


**DESCRIÇÃO:**
Neste laboratório, iremos praticar conceitos fundamentais de gerenciamento de instâncias EC2 na AWS, com foco em criação e utilização de AMIs (Amazon Machine Images) e Snapshots EBS.

---



🟦 **Gerenciamento de Instâncias EC2 na AWS — AMIs, Snapshots e Automação**

Este repositório faz parte do Bootcamp TQI – Modernização com GenAI, contendo documentação e scripts para gerenciar recursos EC2 na AWS, incluindo:

• Criação de AMIs

• Criação de Snapshots EBS

• Restauração de volumes

• Lançamento de instâncias a partir de AMIs

• Infraestrutura como código com Terraform

• Documentação técnica completa

• Estrutura profissional de pastas


Este projeto serve como guia de estudos, prática e referência futura para administração de ambientes EC2.


---

📁 **Estrutura de Pastas do Repositório**

<img width="928" height="1048" alt="Screenshot_20251118-145547" src="https://github.com/user-attachments/assets/6be4e69d-1d4d-405f-924d-364b9b4706c5" />



---

📂 **Descrição Completa de Cada Pasta e Arquivo**




🗂️ **1. Pasta /scripts — Automação via AWS CLI**

Scripts escritos em Bash para facilitar operações recorrentes no EC2.

▶️ **scripts/create_ami.sh**

Cria uma AMI (Amazon Machine Image) a partir de uma instância EC2 existente.

Inclui:

Validação de parâmetros

Tagging automático

Retorno do AMI ID


Uso:

./create_ami.sh <INSTANCE_ID> <AMI_NAME>


---

▶️ **scripts/create_snapshot.sh**

Cria um Snapshot EBS a partir de um volume existente.

Uso:

./create_snapshot.sh <VOLUME_ID> <DESCRIPTION>


---

▶️ **scripts/restore_volume_from_snapshot.sh**

Restaura um novo volume com base em um snapshot.

Uso:

./restore_volume_from_snapshot.sh <SNAPSHOT_ID> <AVAILABILITY_ZONE>


---

▶️ **scripts/launch_instance_from_ami.sh**

Lança uma instância EC2 com base em uma AMI.

Parâmetros:

AMI ID

Tipo da instância

Par de chaves

Security Group

Subnet


Uso:

./launch_instance_from_ami.sh <AMI_ID> <INSTANCE_TYPE> <KEY_NAME> <SG_ID> <SUBNET_ID>


---

🗂️ **2. .gitignore**

Inclui regras para ignorar:

Chaves e certificados (.pem, .ppk)

Arquivos temporários

Cache

Arquivos sensíveis

Diretórios do Terraform

Logs

Configurações específicas do sistema operacional


Essencial para manter o repositório limpo e seguro.


---

🗂️ **3. Pasta /terraform — Infraestrutura como Código**

Contém arquivos Terraform, permitindo subir EC2, VPCs e recursos AWS de forma reprodutível.

📄 **main.tf**

Define a infraestrutura:

Provedor AWS

Instância EC2

Security group

Volume EBS opcional


Exemplo de recursos contidos:

resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "EC2-Gerenciada-Terraform"
  }
}


---

📄 **variables.tf**

Declara variáveis:

Região

AMI

Tipo de instância

Tags

Chave SSH


Organiza e parametriza o projeto Terraform.


---

🗂️ **4. Pasta /docs — Documentação Complementar**

📄 docs/EC2_AMI_Snapshot_Guide.md

Explica detalhadamente:

O que são AMIs

O que são snapshots

Boas práticas

Como executar cada operação na AWS

Como automatizar processos


Serve como material de estudo e consulta técnica.


---

📄 **docs/imagens_e_comentarios.md**

Arquivo opcional contendo:

Explicações adicionais

Comentários sobre o laboratório

Observações sobre as capturas de tela



---

🗂️ **5. Pasta /images**

Contém capturas de tela utilizadas no guia principal ou documentação complementar.

🖼️ **images/captura tela.png**

Exemplo visual de:

Criação de AMI

Criação de snapshot

Dashboard EC2

Execução de instâncias



---

 **Requisitos de Hardware e Software**




**Hardware (mínimo recomendado)**

**Recurso	Requisito**

RAM	4 GB (mínimo), 8 GB recomendado
Armazenamento	10 GB livres
Processador	2 núcleos
Internet	10 Mbps estável



---

**Software Necessário**

 Local (máquina do usuário)

Git

AWS CLI v2

Terraform 1.x

Editor de código (VS Code recomendado)

Ferramentas opcionais:

jq (para parse JSON)

Bash Shell (Linux / macOS / Windows WSL)




---

 **Na AWS**

**Conta AWS ativa**

IAM User com permissões:

ec2:RunInstances

ec2:CreateImage

ec2:CreateSnapshot

ec2:RegisterImage

ec2:AttachVolume

ec2:Describe*




---

 **Tecnologias Utilizadas**

**Tecnologia	Uso**

AWS EC2	Criação de instâncias, volumes e imagens
AWS EBS	Snapshots e volumes persistentes
AWS CLI	Automação via scripts
Terraform	Infraestrutura como código
Linux Bash	Scripts automatizados
Git / GitHub	Versionamento e documentação
Markdown	Documentação técnica
jq	Manipulação de JSON nos scripts



---

 **Como Executar o Projeto**


---

1️⃣ **Clone o repositório**

git clone https://github.com/Santosdevbjj/gerenciaInstanciaEC2.git
cd gerenciaInstanciaEC2


---

2️⃣ **Configure suas credenciais AWS**

aws configure

Informe:

Access Key

Secret Key

Região (ex: us-east-1)

Formato JSON



---

3️⃣ **Execute os scripts Bash**

🔹 **Criar AMI**

./scripts/create_ami.sh i-0123456789abcdef MeuBackupAMI


---

🔹 **Criar Snapshot**

./scripts/create_snapshot.sh vol-0abc123def456 "Snapshot de teste"


---

🔹 **Restaurar volume**

./scripts/restore_volume_from_snapshot.sh snap-0123abc us-east-1a


---

🔹 **Lançar instância EC2**

./scripts/launch_instance_from_ami.sh ami-01234567 t3.micro MinhaKey sg-123abc subnet-456def


---

 4️⃣ **Executar Infraestrutura via Terraform**

Inicializar:

cd terraform
terraform init

Validar:

terraform validate

Planejar:

terraform plan

Criar recursos:

terraform apply -auto-approve

Destruir recursos:

terraform destroy -auto-approve


---

 **Conclusão**

Este projeto consolida habilidades essenciais de gerenciamento EC2:

Criação de AMIs

Gestão de Snapshots EBS

Automação com scripts

IaC com Terraform

Documentação profissional

Uso avançado de GitHub







---


**Autor:**
Sergio Santos 

---

**Contato:**

[![Portfólio Sérgio Santos](https://img.shields.io/badge/Portfólio-Sérgio_Santos-111827?style=for-the-badge&logo=githubpages&logoColor=00eaff)](https://portfoliosantossergio.vercel.app)

[![LinkedIn Sérgio Santos](https://img.shields.io/badge/LinkedIn-Sérgio_Santos-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/santossergioluiz)

---




