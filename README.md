### Gerenciando Instâncias EC2 na AWS.

![TQI](https://github.com/user-attachments/assets/8e63b328-1333-4a08-945b-43cb041cc59f)


**Bootcamp TQI - Modernização com GenAI**

---

**Projeto: Gerenciando Instâncias EC2 na AWS**
Repositório: https://github.com/Santosdevbjj/gerenciaInstanciaEC2

### Sumário
1. Descrição do projeto  
2. Objetivos de aprendizagem  
3. Estrutura do repositório (esquema visual)  
4. Pré-requisitos (hardware / software / permissões)  
5. Passo-a-passo detalhado
   - Criar uma instância EC2 (Console)
   - Conectar via SSH
   - Criar AMI (Console e AWS CLI)
   - Criar Snapshot EBS (Console e AWS CLI)
   - Restaurar volume a partir de Snapshot
   - Lançar nova instância a partir de AMI
   - Compartilhar e permissões de AMI
   - Limpeza de recursos
6. Scripts e automações (local `scripts/`)
7. Exemplo Terraform (opcional)
8. Segurança e boas práticas
9. Recursos úteis / referências
10. Estrutura de arquivos e descrição de cada arquivo

---

## 1. Descrição
Laboratório prático para manipular EC2, AMIs e Snapshots EBS. O objetivo é documentar os passos e fornecer scripts reutilizáveis para ensinar/replicar o fluxo de criação de imagens e recuperação.

## 2. Objetivos de aprendizagem
- Criar e gerenciar instâncias EC2.
- Gerar AMIs a partir de instâncias em execução.
- Criar Snapshots de volumes EBS.
- Restaurar volumes a partir de Snapshots.
- Automatizar processos com AWS CLI / scripts / Terraform.
- Documentar procedimentos e organizar em repositório GitHub.

## 3. Estrutura do repositório


<img width="964" height="985" alt="Screenshot_20251118-030919" src="https://github.com/user-attachments/assets/880046c0-79b6-4437-88c8-6a6caa3cb693" />




---

## 4. Pré-requisitos (HW / SW / Permissões)
**Hardware (máquina local):**
- CPU: 2+ cores (qualquer laptop moderno serve)
- RAM: 4GB+ recomendado
- Espaço disco: 2GB+ livre para scripts/logs

**Software (local):**
- Git (≥2.x)
- AWS CLI v2 configurado (`aws configure`) — credenciais com permissão EC2/IAM/EC2:CreateImage, ec2:CreateSnapshot, ec2:CreateVolume, ec2:RunInstances etc.
- SSH client (`ssh`, `putty` no Windows)
- (Opcional) Terraform se for usar `terraform/` (versão 1.x)

**Permissões AWS necessárias (mínimo)**
- `ec2:RunInstances`, `ec2:TerminateInstances`
- `ec2:CreateImage`, `ec2:DeregisterImage`
- `ec2:CreateSnapshot`, `ec2:DeleteSnapshot`
- `ec2:CreateVolume`, `ec2:AttachVolume`, `ec2:DetachVolume`
- (Opcional) `iam:PassRole` se usar roles

> Use um usuário/role com princípio do menor privilégio. Evite usar credenciais root.

---

## 5. Passo-a-passo detalhado

### A. Criar uma instância EC2 (Console)
1. Acesse AWS Console → EC2 → **Instances** → **Launch instances**.
2. Escolha AMI (Amazon Linux 2 ou Ubuntu LTS para exemplos).
3. Escolha tipo (p.ex. `t3.micro` para Free Tier se elegível).
4. Key pair: selecione ou crie um par de chaves (baixe `.pem` e proteja).
   ```bash
   chmod 400 minha-chave.pem

  

  
---


5. Network / Subnet: escolha VPC/subnet apropriada.


6. Security Group: abra porta 22 (SSH) para seu IP (NUNCA 0.0.0.0/0 em produção).


7. Storage: defina EBS root (p.ex. 8 GiB gp3).


8. Launch instance.



B. Conectar via SSH (Linux / Mac / Windows WSL)

ssh -i ~/keys/minha-chave.pem ec2-user@<PUBLIC_IP>
# ou para Ubuntu
ssh -i ~/keys/minha-chave.pem ubuntu@<PUBLIC_IP>

C. Preparar a instância (ex.: instalar pacotes)

Exemplo (Amazon Linux 2):

sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable --now httpd
echo "Hello from AMI test" | sudo tee /var/www/html/index.html

D. Criar AMI (Console)

1. No Console EC2 → Instances → selecione a instância → Actions → Image and templates → Create image.


2. Preencha nome e descrição. Se desejar sem reboot, marque No Reboot (atenção: pode causar filesystem inconsistente).


3. Clique em Create Image. A AMI aparecerá em AMIs e snapshots dos volumes serão criados automaticamente.



D2. Criar AMI (AWS CLI)

# Substitua REGION e INSTANCE_ID
aws ec2 create-image \
  --region us-east-1 \
  --instance-id i-0123456789abcdef0 \
  --name "minha-ami-exemplo-$(date +%Y%m%d-%H%M)" \
  --description "AMI criada para bootcamp TQI" \
  --no-reboot

Resposta JSON inclui ImageId (p.ex. ami-0abcd1234...).

E. Verificar status da AMI e Snapshots (AWS CLI)

# Verificar AMI
aws ec2 describe-images --image-ids ami-0abcd1234 --region us-east-1

# Ver snapshots associados (filtrar por owner e description)
aws ec2 describe-snapshots --owner-ids self --filters "Name=description,Values=*minha-ami-exemplo*" --region us-east-1

F. Criar Snapshot EBS manualmente (Console)

1. EC2 → Volumes → selecione volume → Actions → Create snapshot.


2. Preencha nome/descrição → Create snapshot.


3. Snapshot aparece em Snapshots.



F2. Criar Snapshot via AWS CLI

# Substitua VOLUME_ID
aws ec2 create-snapshot \
  --region us-east-1 \
  --volume-id vol-0a1b2c3d4e5f6g7h \
  --description "Snapshot do volume root antes de mudança"

Saída retorna SnapshotId (p.ex. snap-0123456789abcdef0).

G. Restaurar volume a partir de Snapshot

# Criar volume a partir do snapshot
aws ec2 create-volume \
  --region us-east-1 \
  --availability-zone us-east-1a \
  --snapshot-id snap-0123456789abcdef0 \
  --volume-type gp3 \
  --size 8
# Depois anexe o volume à instância:
aws ec2 attach-volume --volume-id vol-0abcd1234 --instance-id i-0123456789abcdef0 --device /dev/xvdf

No Linux, você pode então montar (sudo mount /dev/xvdf /mnt/recuperado) e checar dados.

H. Lançar nova instância a partir da AMI (Console)

1. EC2 → AMIs → selecione AMI → Launch.


2. Configure tipo, key pair, security group e storage.


3. Launch.



**I. Compartilhar / Permissões de AMI**

Console → AMIs → Actions → Modify Image Permissions → Compartilhar com contas AWS específicas ou tornar pública (evite tornar pública em produção).

Se AMI utilizar snapshots cifrados, compartilhamento possui limitações (snapshots cifrados NÃO podem ser compartilhados diretamente).


**J. Limpeza (importantíssimo)**

Deregister AMI:

aws ec2 deregister-image --image-id ami-0abcd1234 --region us-east-1

**Deletar snapshots associados:**

aws ec2 delete-snapshot --snapshot-id snap-0123456789abcdef0 --region us-east-1

Terminar instâncias e deletar volumes não usados.



---



**8. Segurança e boas práticas**

Use Security Groups restritivos (abrir porta 22 apenas para seu IP).

Nunca exponha chaves privadas em repositório.

Use KMS para criptografar volumes/snapshots sensíveis.

Evite --no-reboot em AMIs de produção a menos que entenda o risco.

Automatize limpeza de recursos temporários (snapshots/volumes/amis).

Controle custos com tags e alerta de orçamentos (AWS Budgets).


**9. Recursos úteis**

Documentação AWS EC2 / AMI / Snapshots (link oficial)

Documentação GitHub / Markdown (links no repo)


**10. Arquivos e caminhos**

/README.md — este arquivo principal.

/docs/EC2_AMI_Snapshot_Guide.md — guia estendido e screenshots (opcional).

/scripts/*.sh — scripts de automação (create_ami, create_snapshot, restore_volume...).

/terraform/main.tf — exemplo de infra como código.

/images/ — captures de tela usadas no tutorial.


---




Autor:
Sergio Santos 

---




